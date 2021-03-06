function meg_zoomdata(FTData, rawdatapath, pathsavfig, datatyp)
% Genere les figures representant les donnees MEG brutes et les spectres en
% frequence associes.
% Mise en forme tres specifique
if nargin<4
    datatyp='raw';
    typtit='Raw';
else
    switch datatyp
        case 'raw'
            typtit='Raw';
        case 'filt'
            typtit='Filtered';
        otherwise
            typtit=['Preprocessed (',datatyp,')'];
    end
end
if nargin<3 || isempty(dir(pathsavfig))
    pathsavfig=make_dir([pwd,filesep,'FFTplots'],1);
end
if nargin<2
    rawdatapath=pwd;
end

td = FTData.time{1};
xall = FTData.trial{1};

lgc = length(xall(:,1));
nbp = 6; % Une figure par 6 canaux
vfig = 1:nbp:lgc;

% Vecteur utilise pour decaler vers le bas chaque subplot
vputbottom = .008:.005:.008+5*.005;
xlz = [0 10]+100; % Zoom sur le temps
tp = td(td>=xlz(1) & td<xlz(2));
tp = tp - tp(1);
xp = xall(:,td>=xlz(1) & td<xlz(2));
dtpeak = 4; % 4 s autour du pic max

for nf = 1:length(vfig)
    nfs=num2str(nf);
    if length(nfs)==1
        nfss=['0',nfs];
    else
        nfss=nfs;
    end
    figure 
    set(gcf,'Visible','off','units','centimeters','position',[2 2 40 26])
    for ns=1:nbp
        numchan = vfig(nf)+ns-1;
        ip = (ns-1)*7;
        if numchan < lgc
            
            %------
            % Subplot des donnees MEG par canal - toute la duree
            subplot(nbp,7,ip+1:ip+3)
            plot(td, xall(numchan,:))
            %xlim([td(1) td(end)])
            axis tight
            ylabel('Magnetic field (T)')
            xlabel('Time (s)')
            pos=get(gca,'position');
            set(gca,'position',[pos(1)-.05 pos(2)-vputbottom(ns) pos(3)+.05 pos(4)])
            % Fonction put_figtext de la CREx_Toolbox permettant d'apposer
            % du texte sur la figure (coin superieur gauche ici, avec un
            % texte en blanc sur fond noir) - pour indiquer le canal MEG
            put_figtext(FTData.label{numchan},'nw',12,[1 1 1],[0 0 0]);
            % Titre si premiere ligne de subplot de la figure
            if ns==1
                title([typtit,' MEG data per channel'],'fontweight','bold')
            end
            
            %------
            % Subplot des donnees MEG par canal - 10 premieres secondes
            subplot(nbp,7,ip+4:ip+5)
            plot(tp, xp(numchan,:))
            xlim([0 xlz(2)-xlz(1)])
            if min(xp(numchan,:)) < max(xp(numchan,:))
                ylim([min(xp(numchan,:)) max(xp(numchan,:))])
                okdat = 1;
            else
                % Data values are probably zeros
                okdat = 0;
            end
                
            ylabel('Magnetic field (T)')
            xlabel('Time (s)')
            pos=get(gca,'position');
            set(gca,'position',[pos(1)+0.005 pos(2)-vputbottom(ns) pos(3)+.005 pos(4)])
            put_figtext(FTData.label{numchan},'nw',12,[1 1 1],[0 0 0]);
            % Titre si premiere ligne de subplot de la figure
            if ns==1
                title(['10 s from t0=',num2str(xlz(1)),' s'],'fontweight','bold')
            end 
            
            %------
            % Subplot zoom autour du max d'amplitude
            subplot(nbp,7,ip+6:ip+7)
            dtbor = 30;
            tc = td(td>dtbor & td<td(end)-dtbor); % On evite les bords
            xc = xall(numchan, td>dtbor & td<td(end)-dtbor);
            if okdat==1
                [val,indmax] = max(abs(xc));  %#ok
            else
                indmax = round(length(xc)./2);
            end
            indi = find(tc>=tc(indmax)-dtpeak,1,'first');
            indf = find(tc<=tc(indmax)+dtpeak,1,'last');
            plot(tc(indi:indf), xc(indi:indf))
            %xlim([tc(indi) tc(indf)])
            axis tight
            xlabel('Time (s)')
            ylabel('Magnetic field (T)')          
            pos=get(gca,'position');
            set(gca,'position',[pos(1)+.022 pos(2)-vputbottom(ns) pos(3:4)])
            if ns==1
                title('Around maximum amplitude','fontweight','bold')
            end           
        end
    end
    if numchan>lgc
        iend=lgc;
    else
        iend=numchan;
    end
    %------
    % Titre general de la figure contenant le chemin d'acces aux donnees 
    tit={[typtit,' data display -  [',num2str(nf),']']
        ['datapath = ',rawdatapath]};
    annotation(gcf,'textbox','String',tit,'interpreter','none',...
        'FontSize',13,'fontname','AvantGarde',...
        'LineStyle','none','HorizontalAlignment','center',...
        'FitBoxToText','off','Position',[0.1 0.88 0.9 0.12]);

    namfig=['Disp_',datatyp,'Data_',nfss,'_chan_',num2str(vfig(nf)),'_to_',num2str(iend)];
    export_fig([pathsavfig,filesep,namfig,'.jpeg'],'-m1.5','-nocrop')
    close
end

disp(' ')
disp('Look at figures in ---')
disp(['----> ',pathsavfig])
disp(' ')