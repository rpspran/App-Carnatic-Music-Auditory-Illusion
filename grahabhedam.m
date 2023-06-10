function Shrutibhedam(app, event)
            
shrutitemp = [261.62, 277.18, 293.66, 311.12, 329.62, 349.22, 369.99, 391.99, 415.30, 440.00, 466.16, 493.88];
app.shruti=shrutitemp';

%Circular shifting

ainterim=app.a';


b=zeros(13,11);

for i=1:11

b(1,i) = i+1;
b([2:13],i)= circshift(ainterim,12-i);

end


s=sum(b(2,1:11));

c=zeros(13,s);

t=0;

for (i=1:11)
    if b(2,i)==1
        t=t+1;
        c(:,t)=b(:,i);
    end
end
    


c=unique(c','rows')';


%c of 13 cross 6 matrix is generated in which the first row is the swara
%from which Graha bhedam is done
%the rest 12 rows are the 1, 0 binary notation
%there are totally 6 columns which talk about the 6 new scales formed by
%graha bhedam, the 6 columns start with 1, i.e there is definitely a
%Shadjam.

cmelakarta=[];

[norows_c,nocols_c]=size(c);

cmelakarta_colindex=0;

for i=1:nocols_c
 
    tempcolvector=c(:,i);
    temprowvector=tempcolvector';
    
    for melno=1:72
        if isequal(cell2mat(app.T(melno,2)),temprowvector(1,[2:13]))
            cmelakarta_colindex = cmelakarta_colindex + 1;
            cmelakarta(1,cmelakarta_colindex) = temprowvector(1,1);
            cmelakarta(2,cmelakarta_colindex) = melno;
            cmelakarta([3:14],cmelakarta_colindex)=temprowvector(1,[2:13])';
        end
    end
            
    
end

norows_cmelakarta=0;

app.nocols_cmelakarta=0;

[norows_cmelakarta,app.nocols_cmelakarta]=size(cmelakarta);

fprintf('The number of melakarta ragas produced on Graha Bhedam are %d\n',app.nocols_cmelakarta)

    %app.Nograhabhedamragas_melakarta.Value=app.nocols_cmelakarta



%Production of cshruti matrix with zeros for the shifted ragas


cshruti=zeros(15,app.nocols_cmelakarta);

for i = 1:app.nocols_cmelakarta
    cshruti(1,i)=cmelakarta(1,i);
    cshruti(2,i)=cmelakarta(2,i);
    cshruti([3:14],i)=cmelakarta([3:14],i).*app.shruti.*((1.059463)^(cmelakarta(1,i)-1));
    cshruti(15,i)= 523.25.*((1.059463)^(cmelakarta(1,i)-1));
end



%Generation of cshrutinonzeros matrix

noelements_in_cshrutinonzeros=length(nonzeros(cshruti(:,1)));
cshrutinonzeros = zeros(noelements_in_cshrutinonzeros,app.nocols_cmelakarta);

for i=1:app.nocols_cmelakarta
    cshrutinonzeros(1,i)=cshruti(1,i);
    cshrutinonzeros(2,i)=cshruti(2,i);
    cshrutinonzeros([3:noelements_in_cshrutinonzeros],i)=nonzeros(cshruti([3:15],i));
end




[reff,ceff]=size(cshrutinonzeros);



%Tabulation of Note Number and Swara Name

N=cell(12, 2);
          
           N(1,:)={'Sa', 1};
           N(2,:)={'Ri 1', 2};
           N(3,:)={'Ri 2', 3};
           N(4,:)={'Ga 2', 4};
           N(5,:)={'Ga 3', 5};
           N(6,:)={'Ma 1', 6};
           N(7,:)={'Ma 2', 7};
           N(8,:)={'Pa', 8};
           N(9,:)={'Dha 1', 9};
           N(10,:)={'Dha 2', 10};
           N(11,:)={'Ni 2', 11};
           N(12,:)={'Ni 3', 12};

         
           
           
SNo=zeros(ceff,1);          
%Graha_Bhedam_From_Swara=strings([ceff,1]);
Yields_MelakartaNo=zeros(ceff,1);
%MelakartaName=strings([ceff,1]);  
           
Graha_Bhedam_From_Swara=cell(ceff,1);
MelakartaName=cell(ceff,1);

for tdim=1:ceff

notes=[cshrutinonzeros([3:reff],tdim);0;(fliplr(cshrutinonzeros([3:reff],tdim)'))'];
no_of_notes=length(notes);

%  Generating the sound of the raga

Fs        =  12000;  % sampling frequency
repeat    =  1;     % no. of repeatition you want to hear the raga
tim       =  1;      % hear each swara/note for 1 second


%duration of each swara
dur = ones(no_of_notes,1);


% amplitude of sound of each note
amp   = 48 * ones(no_of_notes,1)./60;


% no. of harmonics
nharm = 8;   % (if nharm is 2, note freq f and 2f are added to sound)

% scaling the amplitude of harmonics (exp(1-n)/fac))
fac   = 1;
m = [];
for j = 1:repeat
for i = 1:no_of_notes
x = generate_tone(notes(i),tim*dur(i),amp(i),Fs,nharm,fac);
m = horzcat(m,x);
end
end



    
    
    
noteno=cshrutinonzeros(1,tdim);

%for initializing with random note Ga1
note_name='Ga 1';

for i=1:12
    if i==noteno
        note_name=N(i,1);
    end
end

%note_name=cell2mat(notename);
%note_name_string is the swara name like Sa, Ri, Ga, Ma

%curly braces at end of line 372
note_name_string=note_name{1};

melakarta_no = cshrutinonzeros(2,tdim);

melakarta_name_incell=app.T(melakarta_no,1);

%curly braces at end of line 378
melakarta_name=melakarta_name_incell{1};


SNo(tdim,1)=tdim;
Yields_MelakartaNo(tdim,1)=melakarta_no;
Graha_Bhedam_From_Swara(tdim,1)=note_name;
MelakartaName(tdim,1)=melakarta_name_incell;



fprintf('%d. The notes when shifted from the swara %s give the scale of melakarta no. % d %s \n', tdim,note_name_string,melakarta_no,melakarta_name) 

sound(m,Fs)
pause(20)



end


%Cell to string
Shruthi_Bhedam_From_Swara=char(Graha_Bhedam_From_Swara);
Melakarta_Raga=char(MelakartaName);

%tout = table('size',[ceff 4],'VariableTypes',{'int8','string','int8','string'});          
% tout = table(SNo,Shruthi_Bhedam_From_Swara,Yields_MelakartaNo,Melakarta_Raga);


%All converted to cell form

SNo_cell=num2cell(SNo);
Yields_MelakartaNo_cell=num2cell(Yields_MelakartaNo);


Graha_Bhedam_Ragas=table(SNo_cell, Graha_Bhedam_From_Swara, Yields_MelakartaNo_cell, MelakartaName);
Graha_Bhedam_Melakarta_Ragas=table(SNo_cell, Graha_Bhedam_From_Swara, Yields_MelakartaNo_cell, MelakartaName)

Uitable_data=[Graha_Bhedam_From_Swara Yields_MelakartaNo_cell MelakartaName];

% f=uifigure;
% uit = uitable('Parent', f,'Data',magic(10))


f = figure('Position', [100 100 752 250]);

t = uitable('Parent', f, 'Position', [25 50 700 200], 'Data', Uitable_data);
t.ColumnName = {'Graha Bhedam from Swara', 'Yields Melakarta No.', 'Melakarta Raga'};
t.ColumnWidth = {'auto', 'auto', 300};
t.FontSize=12;

%uit.ColumnName = {'SNo','Swara','Mela No','Raga'};










%Commencement of work on Shadjama Panchama Varjyam



load('testovaci_janyaragas', 'janyaragas')

app.J=janyaragas;

%Specific Segment for Shadjama Panchama Varjyam
%Circular shifting

ainterimspv=app.a';

ainterimspv(1,1)=0;
ainterimspv(8,1)=0;

bspv=zeros(13,11);

for i=1:11

bspv(1,i) = i+1;
bspv([2:13],i)= circshift(ainterimspv,12-i);

end


sspv=sum(bspv(2,1:11));

cspv=zeros(13,sspv);

t=0;

for i=1:11
    if bspv(2,i)==1
        t=t+1;
        cspv(:,t)=bspv(:,i);
    end
end
    


cspv=unique(cspv','rows')';


%c of 13 cross 6 matrix is generated in which the first row is the swara
%from which Graha bhedam is done
%the rest 12 rows are the 1, 0 binary notation
%there are totally 6 columns which talk about the 6 new scales formed by
%graha bhedam, the 6 columns start with 1, i.e there is definitely a
%Shadjam.

moverall_spv=[];

cjanyaspv=[];

[norows_cspv,nocols_cspv]=size(cspv);

cjanyaspv_colindex=0;

for i=1:nocols_cspv
 
    tempcolvector=cspv(:,i);
    temprowvector=tempcolvector';
    
    for janyano=1:norows_cspv
        if isequal(cell2mat(app.J(janyano,2)),temprowvector(1,[2:13]))
            cjanyaspv_colindex = cjanyaspv_colindex + 1;
            cjanyaspv(1,cjanyaspv_colindex) = temprowvector(1,1);
            cjanyaspv(2,cjanyaspv_colindex) = janyano;
            cjanyaspv([3:14],cjanyaspv_colindex)=temprowvector(1,[2:13])';
        end
    end
            
    
end

norows_cjanyaspv=0;

app.nocols_cjanyaspv=0;

[norows_cjanyaspv,app.nocols_cjanyaspv]=size(cjanyaspv);

fprintf('With Shadjam & Panchama Varjyam, number of ragas produced on Graha Bhedam are %d\n',app.nocols_cjanyaspv)

%Production of cshruti matrix with zeros for the shifted ragas
cshrutispv=zeros(15,app.nocols_cjanyaspv);

for i = 1:app.nocols_cjanyaspv
    cshrutispv(1,i)=cjanyaspv(1,i);
    cshrutispv(2,i)=cjanyaspv(2,i);
    cshrutispv([3:14],i)=cjanyaspv([3:14],i).*app.shruti.*((1.059463)^(cjanyaspv(1,i)-1));
    cshrutispv(15,i)=523.25.*((1.059463)^(cjanyaspv(1,i)-1));

end



%Generation of cshrutinonzeros matrix

noelements_in_cshrutispvnonzeros=length(nonzeros(cshrutispv(:,1)));
cshrutispvnonzeros = zeros(noelements_in_cshrutispvnonzeros,app.nocols_cjanyaspv);



for i=1:app.nocols_cjanyaspv
    cshrutispvnonzeros(1,i)=cshrutispv(1,i);
    cshrutispvnonzeros(2,i)=cshrutispv(2,i);
    cshrutispvnonzeros([3:noelements_in_cshrutispvnonzeros],i)=nonzeros(cshrutispv([3:15],i));
end


[reff_spv,ceff_spv]=size(cshrutispvnonzeros);

rtemp_spv=reff_spv-2;
rangec1_spv=zeros(rtemp_spv, 16001,ceff_spv);



%Graha_Bhedam_From_Swara=strings([ceff,1]);
%MelakartaName=strings([ceff,1]);  
           

SNo=zeros(ceff_spv,1);          
Graha_Bhedam_From_Swara=cell(ceff_spv,1);
Raga_Name=cell(ceff_spv,1);



for tdim=1:ceff_spv



    
    
    
    
notes=[cshrutispvnonzeros([2:reff_spv],tdim);0;(fliplr(cshrutispvnonzeros([2:reff_spv],tdim)'))'];
no_of_notes=length(notes);

%  Generating the sound of the raga

Fs        =  12000;  % sampling frequency
repeat    =  1;     % no. of repeatition you want to hear the raga
tim       =  1;      % hear each swara/note for 1 second


%duration of each swara
dur = ones(no_of_notes,1);


% amplitude of sound of each note
amp   = 48 * ones(no_of_notes,1)./60;


% no. of harmonics
nharm = 8;   % (if nharm is 2, note freq f and 2f are added to sound)

% scaling the amplitude of harmonics (exp(1-n)/fac))
fac   = 1;
m_spv = [];
for j = 1:repeat
for i = 1:no_of_notes
x = generate_tone(notes(i),tim*dur(i),amp(i),Fs,nharm,fac);
m_spv = horzcat(m_spv,x);

end
end



    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
noteno_spv=cshrutispvnonzeros(1,tdim);

note_name_spv='Ga 1';

for i=1:12
    if i==noteno_spv
        note_name_spv=N(i,1);
    end
end

%note_name=cell2mat(notename);
%note_name_string is the swara name like Sa, Ri, Ga, Ma

note_name_spv_string=note_name_spv{1};

janya_index_no = cshrutispvnonzeros(2,tdim);

janya_name_incell=app.J(janya_index_no,1);
janya_name=janya_name_incell{1};



SNo(tdim,1)=tdim;
Graha_Bhedam_From_Swara(tdim,1)=note_name_spv;
Raga_Name(tdim,1)=janya_name_incell;




fprintf('%d. The notes when shifted from the swara %s give the scale of raga %s \n', tdim,note_name_spv_string,janya_name) 
sound(m_spv,Fs)

pause(20)

end



%All converted to cell form

S_No=num2cell(SNo);

Graha_Bhedam_Ragas_after_Sa_Pa_Varjyam=table(S_No, Graha_Bhedam_From_Swara, Raga_Name)

Uitable2_data=[Graha_Bhedam_From_Swara Raga_Name];


f = figure('Position', [100 100 752 250]);
t2 = uitable('Parent', f, 'Position', [25 50 700 200], 'Data', Uitable2_data);
t2.ColumnName = {'Graha Bhedam from Swara', 'YieldsRaga'};
t2.ColumnWidth = {'auto',300};
t2.FontSize=12;








% Closure of work on Shadjama Panchama Varjyam
            
