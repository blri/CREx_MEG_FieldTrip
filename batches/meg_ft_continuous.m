% MEG_FT_PREPROC
% Pre-traitement des donnees MEG avec les fonctions FieldTrip
% 
% Actions possibles :
% --------------------
% Afficher et sauver la liste des evenements stockes dans les donnees
% Saisir les canaux bruites pour les eliminer des donnees
% Filtrer les donnees
% Lancer les calculs d'ICA
% Sortir les figures des composantes (topographies + signal temporel)
% Indiquer les mauvaises composantes et les oter des donnees
% Visualiser les donnees nettoyees

% ________
% Parameters to adjust

%--- Architecture indiquant l'acc�s aux dossiers conteannt les donnees MEG
p0 = 'H:\PWD'; 
p1 = {  {p0}, 0
        {'Set_01'}, 1 
        {'pure'}, 0
        };

%--- Vecteur des indices des donnees des sujets a traiter selon pmeg
% vdo = [] : tous les dossiers trouves a partir de l'architecture pmeg
% vdo = 1:10; => sur les 10 premieres donnees
% vdo=17; : sur la 17eme donnee
vdo = []; 

%--- Processus a lancer
doEvList = 0;   
doExtractRaw = 0;
doFilt = 0;
doFFT = 0;
doChanCheck = 0;

doBadChan = 0;
doPadArt = 0;

doICA = 0;
doICAfig = 0;
doRejComp = 1;

%--- Options specifiques aux differents calculs

%_doFilt
filtopt = [];
filtopt.type = 'bp'; %'bp'; % Apply filters to the dataset 
% 'none' : None (default) 
% 'hp' : High-pass filter
% 'lp' : Low-pass filter
% 'bp' : Both (Band-pass)
% 'ask' : Ask for it, for each dataset
filtopt.fc = [1 40]; %[0.5 300]; %[0.5 300]; % Cut-off frequency of high-pass filter
filtopt.datatyp = 'raw'; %'raw'; %'clean'; % Prefix of mat data to filter in data directory 
filtopt.figflag = 1;

%_doFFT : Type de donnees sur lesquelles calculer les FFT (pr�fixe du nom
% des matrices, ex. : 'filt' ou 'raw'
fftopt = [];
fftopt.datatyp = 'filt'; 

%_doChanCheck : Type de donnees a utiliser pour sortir les figures de
% representant les valeurs moyennes de l'enveloppe de Hilbert par capteur
ccopt = [];
ccopt.datatyp = 'filt';

%_doICA
icaopt = [];
icaopt.datatyp = 'filt';
icaopt.numcomp = 'all'; % 'all'

%_doBadChan
badopt = [];
badopt.datatyp = 'filt'; % '4d' , 'filt' , 'clean' ....
badopt.disptool.name = 'none';
% Nom de la methode utilisee pour visualiser les 
% donnees afin de reperer les voies bruitees a supprimer
% 'anywave' (lancement de AnyWave.exe)
% 'ftbrowser' (fonction ft_databrowser)
% 'none' : pas de visualisation (les voies a oter sont demandees
%          directement) [DEFAULT]
% Voir la fonction meg_check_chan pour plus d'infos...

% ________

load_CREx_pref
ft_defaults % Add FieldTrip subdirectory

datapaths = make_pathlist(p1);
if ~isempty(vdo)
    datapaths = datapaths(vdo);
end
Ndp = length(datapaths);

% ________
% Lists of events found in dataset
if doEvList==1
    dirlist = make_dir(fullfile(p0, 'All_events_lists'));
    for np = 1 : Ndp
        disp_progress(np, Ndp);
        meg_read_events(datapaths{np}, dirlist);
    end
end

% ________
% Extract raw data set
if doExtractRaw==1
    for np = 1 : Ndp
        disp_progress(np, Ndp);
        fprintf('\nProcessing of data in :\n%s\n\n',datapaths{np});
        rawData = meg_extract4d(datapaths{np});
        if ~isempty(rawData)
            save([datapaths{np},filesep,'rawData.mat'],'rawData')
        end
    end
end

% ________
% Apply filter to the dataset if filtopt.type~='none'
if doFilt==1
    for np = 1 : Ndp
        disp_progress(np, Ndp);
        meg_cleanup_filt(datapaths{np}, filtopt)
    end
end

% ________
% FFT calculation on fftopt.datatyp data set
if doFFT==1
    for np = 1 : Ndp
        disp_progress(np, Ndp);
        meg_cleanup_fft(datapaths{np}, fftopt)
    end
end
 
% ________
% Check relative mean value of envelope signal over all channels
if doChanCheck==1
    for np = 1 : Ndp
        disp_progress(np, Ndp);
        meg_cleanup_chancheck(datapaths{np}, ccopt)
    end
end

% ________
% Check for BAD channels to remove from dataset
if doBadChan==1
    for np = 1 : Ndp
        disp_progress(np, Ndp);
        badopt = meg_cleanup_badchan(datapaths{np},badopt);
    end
end

    
% ________
% Exclude artefact window on all channels
% by padding by miror of the surrounding data
if doPadArt==1
    for np = 1 : Ndp
        disp_progress(np, Ndp);
        meg_cleanup_padart(datapaths{np})
    end
end

% ________
% ICA processing : analysis of ICA component to remove artefacts
% 
if doICA==1
    for np = 1 : Ndp
        disp_progress(np, Ndp);
        meg_cleanup_ICAproc(datapaths{np}, icaopt)
    end
end

% ________
% ICA component analysis plots
% 
if doICAfig==1
    for np = 1 : Ndp
        disp_progress(np, Ndp);
        meg_cleanup_ICAplot(datapaths{np})
    end
end

% ________
% Reject component(s) in dataset
% 
if doRejComp==1
    % To go faster, we enter first all components to be removed - for
    % all data sets. The components are then actually removed.
    
    % - - - 
    % Input of bad components for all datasets
    allbad = cell(length(vdo),1);
    b = 1;
    for np = 1 : Ndp
        disp_progress(np, Ndp);
        
        allbad{b} = meg_rmcomp_input(datapaths{np});
        b = b+1;
    end
    
    % - - - 
    % Remove it    
    b = 1;
    for np = 1 : Ndp
        disp_progress(np, Ndp);

        meg_cleanup_rmICA(datapaths{np},allbad{b})
        b = b+1;
    end
end



