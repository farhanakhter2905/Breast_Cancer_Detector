function varargout = guidemo(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guidemo_OpeningFcn, ...
                   'gui_OutputFcn',  @guidemo_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before guidemo is made visible.
function guidemo_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for guidemo
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% --- Outputs from this function are returned to the command line.
function varargout = guidemo_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Browse.
function Browse_Callback(hObject, eventdata, handles)
   [filename, pathname] = uigetfile('*.jpg', 'Pick a Image');
    if isequal(filename,0) || isequal(pathname,0)
       warndlg('User pressed cancel')
    else
    filename=strcat(pathname,filename);
    
    InputImage=imread(filename);
    
    axes(handles.axes1);
    imshow(InputImage);
    
    handles.InputImage=InputImage;
    end
    % Update handles structure
guidata(hObject, handles);


% --- Executes on button press in AdaptiveMedianFilter.
function AdaptiveMedianFilter_Callback(hObject, eventdata, handles)
        InputImage=handles.InputImage;
        GrayScaleImage=rgb2gray(InputImage);  
        NoisyImage=GrayScaleImage;
        NoisyImage=double(GrayScaleImage);
        [R C P]=size(NoisyImage);
        OutImage=zeros(R,C);
        Zmin=[];
        Zmax=[];
        Zmed=[];
        for i=1:R
            for j=1:C
                       if (i==1 & j==1)
                            % for right top corner[8,7,6]
                        elseif (i==1 & j==C)
                            % for bottom left corner[2,3,4]
                        elseif (i==R & j==1)
                            % for bottom right corner[8,1,2]
                        elseif (i==R & j==C)
                            %for top edge[8,7,6,5,4]
                        elseif (i==1)
                            % for right edge[2,1,8,7,6]
                        elseif (i==R)
                             % // for bottom edge[8,1,2,3,4]
                        elseif (j==C)
                             %// for left edge[2,3,4,5,6]
                        elseif (j==1)
                       else
                           SR1 = NoisyImage((i-1),(j-1));
                           SR2 = NoisyImage((i-1),(j));
                           SR3 = NoisyImage((i-1),(j+1));
                           SR4 = NoisyImage((i),(j-1));
                           SR5 = NoisyImage(i,j);
                           SR6 = NoisyImage((i),(j+1));
                           SR7 = NoisyImage((i+1),(j-1));
                           SR8 = NoisyImage((i+1),(j));
                           SR9 = NoisyImage((i+1),(j+1));
                           TempPixel=[SR1,SR2,SR3,SR4,SR5,SR6,SR7,SR8,SR9];
                           Zxy=NoisyImage(i,j);
                           Zmin=min(TempPixel);
                           Zmax=max(TempPixel);
                           Zmed=median(TempPixel);
                            A1 = Zmed - Zmin;
                            A2 = Zmed - Zmax;
                           if A1 > 0 && A2 < 0
                           %   go to level B
                                B1 = Zxy - Zmin;
                                B2 = Zxy - Zmax;
                           if B1 > 0 && B2 < 0
                                PreProcessedImage(i,j)= Zxy;
                                     else
                                        PreProcessedImage(i,j)= Zmed;
                                          end
                           else

                             if ((R > 4 && R < R-5) && (C > 4 && C < C-5))

                                         S1 = NoisyImage((i-1),(j-1));
                                         S2 = NoisyImage((i-2),(j-2));
                                         S3 = NoisyImage((i-1),(j));
                                         S4 = NoisyImage((i-2),(j));
                                         S5 = NoisyImage((i-1),(j+1));
                                         S6 = NoisyImage((i-2),(j+2));
                                         S7 = NoisyImage((i),(j-1));
                                         S8 = NoisyImage((i),(j-2));

                                         S9 = NoisyImage(i,j);
                                         S10 = NoisyImage((i),(j+1));
                                         S11 = NoisyImage((i),(j+2));
                                         S12 = NoisyImage((i+1),(j-1));
                                         S13 = NoisyImage((i+2),(j-2));
                                         S14 = NoisyImage((i+1),(j));
                                         S15 = NoisyImage((i+2),(j));
                                         S16 = NoisyImage((i+1),(j+1));
                                         S17 = NoisyImage((i+2),(j+2));
   TempPixel2=[S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13,S14,S15,S16,S17];
                                         Zmed2=median(TempPixel2);
                                         PreProcessedImage(i,j)= Zmed2;
                             else
                                         PreProcessedImage(i,j)= Zmed;
                             end
                        end      
                  end    
            end
        end
        PreProcessedImage3=[]
        PreProcessedImage3(:,:,1)=PreProcessedImage;
        PreProcessedImage3(:,:,2)=PreProcessedImage;
        PreProcessedImage3(:,:,3)=PreProcessedImage;

        PreProcessedImage=PreProcessedImage3;
        PreProcessedImage=uint8(PreProcessedImage);
        axes(handles.axes2);
        imshow(PreProcessedImage,[]);
        handles.PreProcessedImage=PreProcessedImage;
    
    % Update handles structure
guidata(hObject, handles);

warndlg('Process completed'); 
    
    
    


% --- Executes on button press in GMMSegmentation.
function GMMSegmentation_Callback(hObject, eventdata, handles)
        PreProcessedImage=  handles.PreProcessedImage;
        Y=double(PreProcessedImage);
        k=2; % k: number of regions
        g=2; % g: number of GMM components
        beta=1; % beta: unitary vs. pairwise
        EM_iter=10; % max num of iterations
        MAP_iter=10; % max num of iterations
       % fprintf('Performing k-means segmentation\n');
        [X,GMM,ShapeTexture]=image_kmeans(Y,k,g);
        [X,Y,GMM]=HMRF_EM(X,Y,GMM,k,g,EM_iter,MAP_iter,beta);
        Y=Y*80;
        Y=uint8(Y);
        %OutImage=Y;
        Y=rgb2gray(Y);
    Y=double(Y);
    statsa = glcm(Y,0,ShapeTexture);
    ExtractedFeatures1=statsa;
    axes(handles.axes2);
    imshow(Y,[]);
Y=uint8(Y);
    handles.ExtractedFeatures=ExtractedFeatures1;
    disp('exit');    
    handles.gmm=1;
    % Update handles structure
    guidata(hObject, handles);
warndlg('Process completed'); 

% --- Executes on button press in Classifier.
function Classifier_Callback(hObject, eventdata, handles)
gmm=handles.gmm;
load ExtractedFeatures
A=1:20;
B=21:40;
C=41:60;
P = [A B C];
Tc = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1  2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3];
k=2; % k: number of regions
g=2; % g: number of GMM components
beta=1; % beta: unitary vs. pairwise
EM_iter=10; % max num of iterations
MAP_iter=10; % max num of iterations

 file=handles.InputImage;
   file=rgb2gray(file);
    file=adaptivemedian(file);
    [Xk,GMMk,ShapeTexture]=image_kmeans(file,k,g);
    PreProcessedImage(:,:,1)=file;
    PreProcessedImage(:,:,2)=file;
    PreProcessedImage(:,:,3)=file;
    stats= gmmsegmentation(Xk,PreProcessedImage,GMMk,k,g,beta,EM_iter,MAP_iter,ShapeTexture);
    ShapeTexture=stats.ShapeTexture;
    for i=1:60
         statsa=ExtractedFeature{i};
         ShapeTexturea=statsa.ShapeTexture;
         
         diff1(i)=corr2(stats.autoc,statsa.autoc);
         diff2(i)=corr2(stats.contr,statsa.contr);
         diff3(i)=corr2(stats.corrm,statsa.corrm);
         diff4(i)=corr2(stats.cprom,statsa.cprom);
         diff5(i)=corr2(stats.cshad,statsa.cshad);
         diff6(i)=corr2(stats.dissi,statsa.dissi);
         diff7(i)=corr2(stats.energ,statsa.energ);
         diff8(i)=corr2(stats.entro,statsa.entro);
         diff9(i)=corr2(stats.homom,statsa.homom);
         diff10(i)=corr2(stats.homop,statsa.homop);
         diff11(i)=corr2(stats.maxpr,statsa.maxpr);
         diff12(i)=corr2(stats.sosvh,statsa.sosvh);
         diff13(i)=corr2(stats.savgh,statsa.savgh);
         diff14(i)=corr2(stats.svarh,statsa.svarh);
         diff15(i)=corr2(stats.senth,statsa.senth);
         diff16(i)=corr2(stats.dvarh,statsa.dvarh);
         diff17(i)=corr2(stats.denth,statsa.denth);
         diff18(i)=corr2(stats.inf1h,statsa.inf1h);
         diff19(i)=corr2(stats.inf2h,statsa.inf2h);
         diff19(i)=corr2(stats.indnc,statsa.indnc);
         diff19(i)=corr2(stats.idmnc,statsa.idmnc);
         diff20(i)=corr2(ShapeTexture,ShapeTexturea);

    end

    [val1 index1]=max(diff1);
    [val2 index2]=max(diff2);
    [val3 index3]=max(diff3);
    [val4 index4]=max(diff4);
    [val5 index5]=max(diff5);
    [val6 index6]=max(diff6);
    [val7 index7]=max(diff7);
    [val8 index8]=max(diff8);
    [val9 index9]=max(diff9);
    [val10 index10]=max(diff10);
    [val11 index11]=max(diff11);
    [val12 index12]=max(diff12);
    [val13 index13]=max(diff13);
    [val14 index14]=max(diff14);
    [val15 index15]=max(diff15);
    [val16 index16]=max(diff16);
    [val17 index17]=max(diff17);
    [val18 index18]=max(diff18);
    [val19 index19]=max(diff19);
    [val20 index20]=max(diff20);


% for i=1:3, text(P(1,i)+0.1,P(2,i),sprintf('class %g',Tc(i))), end
% axis([0 3 0 3])
% title('Three vectors and their classes.')
% xlabel('P(1,:)')
% ylabel('P(2,:)')

T = ind2vec(Tc);

spread = 1;

net = newpnn(P,T,spread);

A = sim(net,P);
Ac = vec2ind(A);

pl(1) = index20;
p1(2) = index1;
p1(3) = index2;
p1(4) = index3;
p1(5) = index4;
p1(6) = index5;
p1(7) = index6;
p1(8) = index7;
p1(9) = index8;
p1(10) = index9;
p1(11) = index10;
p1(12) = index11;
p1(13) = index12;
p1(14) = index13;
p1(15) = index14;
p1(16) = index15;
p1(17)= index16;
p1(18) = index17;
p1(19) = index18;
p1(20) = index19;


% pl = index20;
a = sim(net,pl);
ac = vec2ind(a);
disp(ac);
ac=num2str(ac)

set(handles.edit1,'String',ac);

warndlg('Process completed'); 