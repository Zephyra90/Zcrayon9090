%%%% AN 88 LINE TOPOLOGY OPTIMIZATION CODE Nov, 2010 %%%%
%%88�г�����99�����ĸĽ���
%1����forѭ�����������������matlab�����������ƣ�
%2��Ϊ�����������ݵ�����Ԥ�����ڴ棬����matlab���Ѷ���ʱ��Ѱ�Ҹ���������ڴ�飻
%3�������ܽ����ֳ����ѭ���������������ظ����㣻
%4����Ʊ������ٴ���Ԫα�ܶȣ���������ʵ�ܶȱ���xphys��
%5����ԭ�ȵ������ӳ��򶼼����������������Ƶ�����ã�
% �����ϣ������Ч�����������������ٱ������ڴ�ռ�ý��ͣ����Գ�ѧ����˵�ɶ��Բ���99��
function top88(nelx,nely,volfrac,penal,rmin,ft)
% nelx-- ˮƽ����Ԫ����
% nely-- ��ֱ����Ԫ����
% volfrac--�ݻ��ʣ������������������֮�ȣ���Ӧ�Ĺ���������ǡ����ṹ���ص��ٷ�֮���١�
% penal--�ͷ����ӣ�ͨ��Ϊ3����SIMP��������0-1��ɢģ����������������x��ϵ��p���м��ܶȵ�Ԫ���Ӷ�����ɢ���Ż�
%����ת�����������Ż����⣬������0��x��1��pΪ�ͷ����ӣ�ͨ���趨p��1���м��ܶȵ�Ԫ�������޶ȵĳͷ�
%���������м��ܶȵ�Ԫ��Ŀ��ʹ��Ԫ�ܶȾ���������0��1��

%����ѡ��ͷ����ӵ�ȡֵ������������ײ��ϣ��Ӷ��õ�����������Ż������
      %��penal<=2ʱ    ���ڴ�����ײ��ϣ����������û�п������ԣ�
      %��penal>=3.5ʱ   �������˽��û�д�ĸı�
      %��penal>=4ʱ    �ṹ������ȵı仯�ǳ������������������ӣ�����ʱ���ӳ���
% rmin--�˲��뾶��ͨ��Ϊ1.5����ֹ�������̸�����
% ft---1-�������˲���2--�ܶ��˲�  ��99�г���ͬ���ǣ��������ṩ�������˲�����ft=1ʱ�����������˲���
                                 %�õ��Ľ����99�г���һ����ft=2ʱ�����ܶ��˲�
nelx=150;nely=100;volfrac=0.5;penal=3;rmin=5;ft=1;
%% MATERIAL PROPERTIES ��������
%E0����ģ����
E0 = 1;

%Emin�Զ�����������ϵ���ģ����Ϊ��ֹ����������������99�г���ͬ���μ����Ĺ�ʽ(1)
%��Ҫ�����0�������û��������
Emin = 1e-3; % Emin = E0/1000
nu = 0.3; % ���ɱ�
passive = zeros(nely,nelx);
for ely = 1:nely
    for elx = 1:nelx
        if sqrt((ely-nely/2.)^2+(elx-nelx/3.)^2) < nely/3.%Բ��Ϊ(nelx/3,nely/2)���뾶Ϊnely/3
%         if elx>nelx/4&&elx<3*nelx/4&&ely>nely/4&&ely<3*nely/4
            passive(ely,elx) = 1;
        end
    end
end
%% PREPARE FINITE ELEMENT ANALYSIS  ����ԪԤ����
% ����ƽ���Ľڵ����Ԫ�ĵ�Ԫ�նȾ���KE���������Ԫ�����Ƶ�
A11 = [12  3 -6 -3;  3 12  3  0; -6  3 12 -3; -3  0 -3 12];
A12 = [-6 -3  0  3; -3 -6 -3 -6;  0 -3 -6  3;  3 -6  3 -6];  
B11 = [-4  3 -2  9;  3 -4 -9  4; -2 -9 -4 -3;  9  4 -3 -4];
B12 = [ 2 -3  4 -9; -3  2  9 -2;  4  9  2  3; -9 -2  3  2];
KE = 1/(1-nu^2)/24*([A11 A12;A12' A11]+nu*[B11 B12;B12' B11]); % ��Ԫ�նȾ���
nodenrs = reshape(1:(1+nelx)*(1+nely),1+nely,1+nelx); % nodenrs��ŵ�Ԫ�ڵ��ţ����������ȵ�˳�򣬴�1��(1+nelx)(1+nely):
edofVec = reshape(2*nodenrs(1:end-1,1:end-1)+1,nelx*nely,1);%������е�Ԫ�ĵ�һ�����ɶȱ��(���½�)
%edofMat�����д��ÿ����Ԫ4���ڵ�8�����ɶȱ�ţ�����������8���������ڵ�Ԫ����
%���˳������ʱ�룺[����x ����y ����x ����y ����x ����y ����x  ����y]��
%��һ��repmat��������edofvec���Ƴ�8�У��������ɶȴӵ�һ�����ɶ��ϼӻ�����Եõ�
edofMat = repmat(edofVec,1,8)+repmat([0 1 2*nely+[2 3 0 1] -2 -1],nelx*nely,1); % �õ���Ԫ�ڵ����ɶȱ�ţ���ʱ�뷽���Ľڵ㣬8���ɶ�

%����ik��jk��sk��Ԫ����������նȾ����ϡ�����K��K = sparse(iK , jK ,sK)
iK = reshape(kron(edofMat,ones(8,1))',64*nelx*nely,1);
jK = reshape(kron(edofMat,ones(1,8))',64*nelx*nely,1);
% DEFINE LOADS AND SUPPORTS (HALF MBB-BEAM)
%U = zeros(2*(nely+1)*(nelx+1),1);
 F = sparse(2*(nely+1)*(nelx+1),1,-1, 2*(nely+1)*(nelx+1),1); % ����һ��2*(nely)*(nelx)��1��ϡ������ڣ�2,1��ֵΪ-1
 fixeddofs = [1:2*nely+1];
 %fixeddofs = union([1:2:2*(nely+1)],[2*(nelx+1)*(nely+1)]); % Ԫ�غϲ�
 %fixeddofs = [2*(nely+1)-1,2*(nely+1),2*(nelx+1)*(nely+1)]; 
%F = sparse([2*(nely+1)*nelx+2,2*(nely+1)*(nelx+1)],[1 2],[1 -1],2*(nely+1)*(nelx+1),2);
U = zeros(2*(nely+1)*(nelx+1),2);
% ������
%F = sparse(2*((nely+1)*(nelx+1)-ceil(nely/2)),1,-1,2*(nely+1)*(nelx+1),1); %ʩ���غɣ�ֱ�ӹ���ϡ�����
%F = sparse(2*(nely+1)*(nelx+1),1,-1, 2*(nely+1)*(nelx+1),1);
%ʩ��Լ������99�г�����ͬ��Ψһ������������ѡ������غ�Լ��������ѭ�����⣬���Ч��
%fixeddofs = [1:2*(nely+1)]; 
alldofs = [1:2*(nely+1)*(nelx+1)];
freedofs = setdiff(alldofs,fixeddofs); % ��������Ĳ�ͬ����setdiff��A,B��--A-B
%% PREPARE FILTER �˲�׼��
% ����iH��jH��sH��Ԫ�����ɼ�Ȩϵ������H��H = sparse(iH,jH,sH);
% H�����Ĺ�ʽ(8)�е�Hei,Hs�����Ĺ�ʽ(9)�е�sigma(Hei);

% Ϊ����iH��jH��sHԤ�����ڴ棻
iH = ones(nelx*nely*(2*(ceil(rmin)-1)+1)^2,1); % ceil--���������ȡ��
jH = ones(size(iH));
sH = zeros(size(iH));
k = 0;

% 4��forѭ����ǰ����i1��j1�Ǳ������е�Ԫ��������i2��j2�Ǳ�����ǰ��Ԫ�����ĵ�Ԫ
% �������ȹ��˼����ı��������ù��˰뾶��Χ�ڸ���Ԫ���ȵļ�Ȩƽ��ֵ�������ĵ�Ԫ������ֵ
for i1 = 1:nelx
  for j1 = 1:nely
    e1 = (i1-1)*nely+j1;  % ��Ԫ��
    for i2 = max(i1-(ceil(rmin)-1),1):min(i1+(ceil(rmin)-1),nelx)
      for j2 = max(j1-(ceil(rmin)-1),1):min(j1+(ceil(rmin)-1),nely)
        e2 = (i2-1)*nely+j2;
        k = k+1;
        iH(k) = e1;
        jH(k) = e2;
        sH(k) = max(0,rmin-sqrt((i1-i2)^2+(j1-j2)^2)); % λ��
      end
    end
  end
end
H = sparse(iH,jH,sH); %�����С nelx*nely ,nelx*nely
Hs = sum(H,2); % ����Hÿ�����
%% INITIALIZE ITERATION ������ʼ��
x = repmat(volfrac,nely,nelx); % x��Ʊ��� �����СΪnely*nelx ֵΪvolfrac
%x(find(passive)) = 0.001; % find(passive) ����passive�з���Ԫ�ص����
xPhys = x;               % xphys��Ԫ�����ܶȣ������ܶȣ�������99�в�һ����
loop = 0;                % loop��ŵ�������
change = 1;
%% START ITERATION �����Ż�����������Ϊֹ����Ĳ��ֶ�����ѭ���⣬��99��Ч����ߺܶ�
while change > 0.01
  loop = loop + 1;
  %% FE-ANALYSIS ����Ԫ�������
  % (Emin+xPhys(:)',^penal*(E0-Emin))�������Ĺ�ʽ(1)���ɵ�Ԫ�ܶȾ������ϵ���ģ����
  sK = reshape(KE(:)*(Emin+xPhys(:)'.^penal*(E0-Emin)),64*nelx*nely,1);
  
  % ��װ����նȾ����ϡ�����
  % K = (K+K')/2ȷ������նȾ�������ȫ�Գ�����Ϊ���Ӱ�쵽MATLAB�������Ԫ���̵��㷨��
  % ��K��ʵ�Գ���������ʱ�����Choleskyƽ�����ֽⷨ����֮������ٶȸ�����LU���Ƿֽⷨ��
  K = sparse(iK,jK,sK); K = (K+K')/2;
  
  % ��ʽ��⣬KU=F��
  U(freedofs) = K(freedofs,freedofs)\F(freedofs);
 %U(freedofs,:) = K(freedofs,freedofs)\F(freedofs,:);
  %% OBJECTIVE FUNCTION AND SENSITIVITY ANALYSIS Ŀ�꺯���͹�����ʵ�ܶȳ�����������Ϣ
  % �μ�����(2)��ce��ue^T*k0*ue��cĿ�꺯����
  %ce = reshape(sum((U(edofMat)*KE).*U(edofMat),2),nely,nelx); % sum(A,2)---A���������
  %c = sum(sum((Emin+xPhys.^penal*(E0-Emin)).*ce));
  %dc = -penal*(E0-Emin)*xPhys.^(penal-1).*ce;  % �μ����Ĺ�ʽ(5)��ֻ��������Ʊ���x������ʵ�ܶ�xphys��
  c=0;
dc=0;
for i = 1:size(F,2)
Ui = U(:,i);
ce = reshape(sum((Ui(edofMat)*KE).*Ui(edofMat),2),nely,nelx);
c = c + sum(sum((Emin+xPhys.^penal*(E0-Emin)).*ce));
dc = dc - penal*(E0-Emin)*xPhys.^(penal-1).*ce;
  end
 dv = ones(nely,nelx);                       % �μ����Ĺ�ʽ(6)
  %% FILTERING/MODIFICATION OF SENSITIVITIES  �����˲� �� �ܶ��˲�
  if ft == 1
      % ft=1�������˲����õ��Ľ��ͬ99�г��򣩣��μ����Ĺ�ʽ(7);
      % ��������˲���
      % 1e-3�ǹ�ʽ(7)�е�gamma��max(1e-3,x(:))��Ϊ�˷�ֹ��ĸ����0��
    dc(:) = H*(x(:).*dc(:))./Hs./max(1e-3,x(:));
  elseif ft == 2
      % ft=2�ܶ��˲�
      % �ܶ��˲���������������һ�����ܶ��˲����������ѭ������
      % ��һ���Ǹ�����ʽ��������Ŀ�꺯�������Լ������������Ϣ����������μ���ʽ(10);
    dc(:) = H*(dc(:)./Hs);
    dv(:) = H*(dv(:)./Hs);
  end
  %% OPTIMALITY CRITERIA UPDATE OF DESIGN VARIABLES AND PHYSICAL DENSITIES      OC�Ż�׼�򷨸�����Ʊ����͵�Ԫ�ܶ�
  l1 = 0; l2 = 1e9; move = 0.2;
  while (l2-l1)/(l1+l2) > 1e-3
    lmid = 0.5*(l2+l1); % �������ճ��� ���ַ�
    
    % ������Ʊ������μ����Ĺ�ʽ(3):
    xnew = max(0,max(x-move,min(1,min(x+move,(x.*sqrt(-dc./dv/lmid))))));
    if ft == 1
        % �����˲�û���ܶ��˲���ô���ӣ���Ʊ��������൱�ڵ�Ԫ��α�ܶȣ�
      xPhys = xnew;
    elseif ft == 2
        % ����ܶ��˲����μ����Ĺ�ʽ(9),��Ʊ��������˲�֮����ǵ�Ԫα�ܶȣ�
      xPhys(:) = (H*xnew(:))./Hs;
    end
    xPhys(passive==1) = 0;
    xPhys(passive==2) = 1;
    if sum(xPhys(:)) > volfrac*nelx*nely, l1 = lmid; else l2 = lmid; end
  end
  change = max(abs(xnew(:)-x(:)));
  x = xnew;
  %% PRINT RESULTS ��ʾ�����ͬ99�г���
  fprintf(' It.:%5i Obj.:%11.4f Vol.:%7.3f ch.:%7.3f\n',loop,c,mean(xPhys(:)),change);
  % loop--��������
  % c--���
  % mean(xPhys(:))--���
  % change--�����ж�����
  %% PLOT DENSITIES
  colormap(gray);  % ��ɫӳ��
  imagesc(1-xPhys); % ��ֵ0�����ɫ��1�����ɫ
  caxis([0 1]);  
  axis equal; 
  axis off; 
  drawnow;
end
%
