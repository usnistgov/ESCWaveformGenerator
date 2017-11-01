...%% Legal Disclaimer
...% NIST-developed software is provided by NIST as a public service. 
...% You may use, copy and distribute copies of the software in any medium,
...% provided that you keep intact this entire notice. You may improve,
...% modify and create derivative works of the software or any portion of
...% the software, and you may copy and distribute such modifications or
...% works. Modified works should carry a notice stating that you changed
...% the software and should note the date and nature of any such change.
...% Please explicitly acknowledge the National Institute of Standards and
...% Technology as the source of the software.
...% 
...% NIST-developed software is expressly provided "AS IS." NIST MAKES NO
...% WARRANTY OF ANY KIND, EXPRESS, IMPLIED, IN FACT OR ARISING BY
...% OPERATION OF LAW, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTY
...% OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT
...% AND DATA ACCURACY. NIST NEITHER REPRESENTS NOR WARRANTS THAT THE
...% OPERATION OF THE SOFTWARE WILL BE UNINTERRUPTED OR ERROR-FREE, OR
...% THAT ANY DEFECTS WILL BE CORRECTED. NIST DOES NOT WARRANT OR MAKE ANY 
...% REPRESENTATIONS REGARDING THE USE OF THE SOFTWARE OR THE RESULTS 
...% THEREOF, INCLUDING BUT NOT LIMITED TO THE CORRECTNESS, ACCURACY,
...% RELIABILITY, OR USEFULNESS OF THE SOFTWARE.
...% 
...% You are solely responsible for determining the appropriateness of
...% using and distributing the software and you assume all risks
...% associated with its use, including but not limited to the risks and
...% costs of program errors, compliance with applicable laws, damage to 
...% or loss of data, programs or equipment, and the unavailability or
...% interruption of operation. This software is not intended to be used in
...% any situation where a failure could cause risk of injury or damage to
...% property. The software developed by NIST employees is not subject to
...% copyright protection within the United States.
classdef radarPeaksFinder<radarSignalFromFile
    %radar peaks finder class
    %read read decimated radar file, and save peaks above threshold (if provided) to the same dir
    %Example:
            %radarInputFile='decimatedFilesDir\SanDiego_1_dec01.dat';
            %radarMetaFile='decimatedFilesDir\FileMeta.xlsx';
            %peakThresholdAboveNoise_dB=20;
            %testPeak=radarPeaksFinder(radarInputFile,radarMetaFile,25e6,peakThresholdAboveNoise_dB);
            %testPeak=initRadarPeakFinder(testPeak);
            %testPeak=findRadarPeaks(testPeak);
    %see also radarSignalFromFile
    properties (Constant,Access=private)
            % The following code was used to design the filter coefficients:
    % % FIR Window Lowpass filter designed using the FIR1 function.
    %
    % % All frequency values are in MHz.
    % Fs = 25;  % Sampling Frequency
    %
    % Fpass = 0.5;              % Passband Frequency
    % Fstop = 0.7;              % Stopband Frequency
    % Dpass = 0.057501127785;   % Passband Ripple
    % Dstop = 0.0031622776602;  % Stopband Attenuation
    % flag  = 'scale';          % Sampling Flag
    %
    % % Calculate the order from the parameters using KAISERORD.
    % [N,Wn,BETA,TYPE] = kaiserord([Fpass Fstop]/(Fs/2), [1 0], [Dstop Dpass]);
    %
    % % Calculate the coefficients using the FIR1 function.
    % b  = fir1(N, Wn, TYPE, kaiser(N+1, BETA), flag);
        filterNumerator=[5.46130288086359e-05 7.0017791835293e-05 ...
        8.5298638493902e-05 9.99621921958858e-05 0.000113486761320984 ...
        0.000125336488723233 0.000134977002278342 0.000141892182569012 ...
        0.000145601606246609 0.000145678176173936 0.000141765414091025 ...
        0.000133593869935717 0.000120996095449959 0.000103919639287094 ...
        8.24375470548388e-05 5.67558926713239e-05 2.72179266805678e-05 ...
        -5.69549812332977e-06 -4.1369474661801e-05 -7.90627130828901e-05 ...
        -0.000117919374940764 -0.000156984991140383 -0.000195226262556675 ...
        -0.000231554419185652 -0.000264851693246897 -0.000294000347402221 ...
        -0.000317913594746628 -0.000335567655920229 -0.000346034123827542 ...
        -0.000348511750967102 -0.000342356740794677 -0.000327110614896455 ...
        -0.000302524743487766 -0.000268580668690209 -0.0002255054182957 ...
        -0.000173781101694402 -0.00011414819797888 -4.76020868580428e-05 ...
        2.4617466869354e-05 0.000101043988374661 0.000180009052338833 ...
        0.000259673856343154 0.000338067139451998 0.00041312878210216 ...
        0.000482758236411368 0.000544866762679852 0.000597432293493435 ...
        0.000638555616477497 0.000666516465006716 0.000679828037087168 ...
        0.000677288429538237 0.000658027480037235 0.000621547555157031 ...
        0.000567756908834184 0.000496994362304274 0.000410044221897378 ...
        0.000308140552574647 0.000192960159017081 6.66038877501559e-05 ...
        -6.8433852422985e-05 -0.000209307154941961 -0.000352871760203195 ...
        -0.000495748466765166 -0.00063439569345507 -0.000765189790074102 ...
        -0.000884511430916754 -0.000988836192851201 -0.00107482722554899 ...
        -0.00113942777220428 -0.00117995120045515 -0.00119416615984984 ...
        -0.00118037449749303 -0.00113747963950004 -0.00106504328314805 ...
        -0.000963328442172846 -0.000833327142974537 -0.000676771378460536 ...
        -0.000496126283244957 -0.000294564891887354 -7.59242724347778e-05 ...
        0.000155356718765062 0.000394317348618724 0.00063557140491089 ...
        0.000873418441812896 0.00110196779903894 0.00131527291786199 ...
        0.00150747311941774 0.00167293970827441 0.0018064230267072 ...
        0.00190319692080897 0.0019591969953044 0.00197114903479786 ...
        0.00193668405834585 0.00185443665282286 0.001724123497511 ...
        0.00154659934446204 0.00132388815104047 0.00105918756511309 ...
        0.000756845530051516 0.000422308394659733 6.20405693064418e-05 ...
        -0.000316583550452472 -0.000705413983069706 -0.00109568379267525 ...
        -0.00147818920646947 -0.00184348785539772 -0.00218211121669905 ...
        -0.00248478684987272 -0.00274266561643496 -0.0029475487709131 ...
        -0.00309210961627718 -0.00317010433963179 -0.00317656668917366 ...
        -0.00310798132414716 -0.00296243096592795 -0.00273971289762432 ...
        -0.00244142089594048 -0.00207098932382981 -0.00163369685423575 ...
        -0.00113662811994554 -0.000588592475914921 1.47407534038042e-18 ...
        0.000617304174132122 0.00125024512324971 0.00188475997129023 ...
        0.00250607234499952 0.00309899463302957 0.00364825244942856 ...
        0.00413882501900948 0.00455629463698115 0.00488719792442771 ...
        0.00511937131805371 0.00524228310740463 0.0052473443725526 ...
        0.00512819138350004 0.00488093239909797 0.00450435234413383 ...
        0.00400006954068458 0.00337263951246111 0.00262960185381084 ...
        0.00178146724019567 0.000841642833346552 -0.000173704421531457 ...
        -0.00124584582259642 -0.002353748176335 -0.00347438692503085 ...
        -0.00458311051174515 -0.00565405017650959 -0.00666056829093169 ...
        -0.00757573737190117 -0.00837284109159253 -0.00902588794081166 ...
        -0.00951012772307434 -0.00980256077115224 -0.00988242969573234 ...
        -0.00973168360262011 -0.00933540505147524 -0.00868219057180099 ...
        -0.00776447629273544 -0.00657880116967507 -0.00512600138631153 ...
        -0.00341133075485941 -0.00144450330623937 0.000760344271057939 ...
        0.00318477114898683 0.00580623106695077 0.00859834888088692 ...
        0.0115312710555548 0.0145720847086194 0.0176852984134531 ...
        0.0208333766865925 0.0239773189529849 0.0270772728221777 ...
        0.0300931707425986 0.0329853785463049 0.0357153440659506 ...
        0.0382462339075393 0.0405435466002484 0.0425756907167735 ...
        0.0443145171578504 0.0457357956116944 0.0468196262172606 ...
        0.0475507786594592 0.0479189522808692 0.0479189522808692 ...
        0.0475507786594592 0.0468196262172606 0.0457357956116944 ...
        0.0443145171578504 0.0425756907167735 0.0405435466002484 ...
        0.0382462339075393 0.0357153440659506 0.0329853785463049 ...
        0.0300931707425986 0.0270772728221777 0.0239773189529849 ...
        0.0208333766865925 0.0176852984134531 0.0145720847086194 ...
        0.0115312710555548 0.00859834888088692 0.00580623106695077 ...
        0.00318477114898683 0.000760344271057939 -0.00144450330623937 ...
        -0.00341133075485941 -0.00512600138631153 -0.00657880116967507 ...
        -0.00776447629273544 -0.00868219057180099 -0.00933540505147524 ...
        -0.00973168360262011 -0.00988242969573234 -0.00980256077115224 ...
        -0.00951012772307434 -0.00902588794081166 -0.00837284109159253 ...
        -0.00757573737190117 -0.00666056829093169 -0.00565405017650959 ...
        -0.00458311051174515 -0.00347438692503085 -0.002353748176335 ...
        -0.00124584582259642 -0.000173704421531457 0.000841642833346552 ...
        0.00178146724019567 0.00262960185381084 0.00337263951246111 ...
        0.00400006954068458 0.00450435234413383 0.00488093239909797 ...
        0.00512819138350004 0.0052473443725526 0.00524228310740463 ...
        0.00511937131805371 0.00488719792442771 0.00455629463698115 ...
        0.00413882501900948 0.00364825244942856 0.00309899463302957 ...
        0.00250607234499952 0.00188475997129023 0.00125024512324971 ...
        0.000617304174132122 1.47407534038042e-18 -0.000588592475914921 ...
        -0.00113662811994554 -0.00163369685423575 -0.00207098932382981 ...
        -0.00244142089594048 -0.00273971289762432 -0.00296243096592795 ...
        -0.00310798132414716 -0.00317656668917366 -0.00317010433963179 ...
        -0.00309210961627718 -0.0029475487709131 -0.00274266561643496 ...
        -0.00248478684987272 -0.00218211121669905 -0.00184348785539772 ...
        -0.00147818920646947 -0.00109568379267525 -0.000705413983069706 ...
        -0.000316583550452472 6.20405693064418e-05 0.000422308394659733 ...
        0.000756845530051516 0.00105918756511309 0.00132388815104047 ...
        0.00154659934446204 0.001724123497511 0.00185443665282286 ...
        0.00193668405834585 0.00197114903479786 0.0019591969953044 ...
        0.00190319692080897 0.0018064230267072 0.00167293970827441 ...
        0.00150747311941774 0.00131527291786199 0.00110196779903894 ...
        0.000873418441812896 0.00063557140491089 0.000394317348618724 ...
        0.000155356718765062 -7.59242724347778e-05 -0.000294564891887354 ...
        -0.000496126283244957 -0.000676771378460536 -0.000833327142974537 ...
        -0.000963328442172846 -0.00106504328314805 -0.00113747963950004 ...
        -0.00118037449749303 -0.00119416615984984 -0.00117995120045515 ...
        -0.00113942777220428 -0.00107482722554899 -0.000988836192851201 ...
        -0.000884511430916754 -0.000765189790074102 -0.00063439569345507 ...
        -0.000495748466765166 -0.000352871760203195 -0.000209307154941961 ...
        -6.8433852422985e-05 6.66038877501559e-05 0.000192960159017081 ...
        0.000308140552574647 0.000410044221897378 0.000496994362304274 ...
        0.000567756908834184 0.000621547555157031 0.000658027480037235 ...
        0.000677288429538237 0.000679828037087168 0.000666516465006716 ...
        0.000638555616477497 0.000597432293493435 0.000544866762679852 ...
        0.000482758236411368 0.00041312878210216 0.000338067139451998 ...
        0.000259673856343154 0.000180009052338833 0.000101043988374661 ...
        2.4617466869354e-05 -4.76020868580428e-05 -0.00011414819797888 ...
        -0.000173781101694402 -0.0002255054182957 -0.000268580668690209 ...
        -0.000302524743487766 -0.000327110614896455 -0.000342356740794677 ...
        -0.000348511750967102 -0.000346034123827542 -0.000335567655920229 ...
        -0.000317913594746628 -0.000294000347402221 -0.000264851693246897 ...
        -0.000231554419185652 -0.000195226262556675 -0.000156984991140383 ...
        -0.000117919374940764 -7.90627130828901e-05 -4.1369474661801e-05 ...
        -5.69549812332977e-06 2.72179266805678e-05 5.67558926713239e-05 ...
        8.24375470548388e-05 0.000103919639287094 0.000120996095449959 ...
        0.000133593869935717 0.000141765414091025 0.000145678176173936 ...
        0.000145601606246609 0.000141892182569012 0.000134977002278342 ...
        0.000125336488723233 0.000113486761320984 9.99621921958858e-05 ...
        8.5298638493902e-05 7.0017791835293e-05 5.46130288086359e-05];
% filterNumerator=[-8.2930464923808e-06 -2.22280907932016e-05 ...
%             -3.70080154888737e-05 -5.11020471573871e-05 -6.27800853369776e-05 ...
%             -7.02813275755504e-05 -7.20102497793814e-05 -6.6741305300701e-05 ...
%             -5.38105698578391e-05 -3.32714845874957e-05 -5.99315907014781e-06 ...
%             2.63165145053395e-05 6.11745779029926e-05 9.547719648086e-05 ...
%             0.00012573873823221 0.000148400563620473 0.000160185359469889 ...
%             0.000158465470564327 0.000141608836941406 0.000109264579410146 ...
%             6.25524649174397e-05 4.12655718676372e-06 -6.19069403072163e-05 ...
%             -0.000130224962972193 -0.000194668654036387 -0.000248747580313544 ...
%             -0.000286229952374194 -0.000301769547733039 -0.000291511640398601 ...
%             -0.000253616778234363 -0.000188643499140986 -9.97393154321195e-05 ...
%             7.39676831242544e-06 0.000124798181747646 0.000242756981640449 ...
%             0.000350564449295843 0.000437415190483179 0.000493403723003926 ...
%             0.000510527533831792 0.000483602555048752 0.000410997280554651 ...
%             0.000295100964072654 0.000142459335201312 -3.64629764492972e-05 ...
%             -0.00022790244705259 -0.000415773182187427 -0.000582938669408671 ...
%             -0.000712685076721033 -0.000790276273843455 -0.000804453788502893 ...
%             -0.000748739391211201 -0.000622405288952844 -0.000430997258952 ...
%             -0.000186328523872935 9.40953813686163e-05 0.000388211292374284 ...
%             0.000671031290049226 0.0009166624199734 0.00110055856448703 ...
%             0.00120181752081207 0.00120531889489314 0.0011034983962935 ...
%             0.000897572696627023 0.000598065748433268 0.000224540219312118 ...
%             -0.000195497257551956 -0.000628476076289571 -0.0010373125988593 ...
%             -0.00138444983906933 -0.0016351477096552 -0.00176074741916856 ...
%             -0.0017416176869983 -0.00156949968209359 -0.00124900273512674 ...
%             -0.000798062393553396 -0.000247252472774547 0.000362062479165916 ...
%             0.000980645990313025 0.00155519104252675 0.00203272543946668 ...
%             0.00236527183654154 0.00251436889222418 0.00245504781556044 ...
%             0.00217888140063813 0.00169578050590084 0.00103430281594055 ...
%             0.000240354585409121 -0.00062570074626459 -0.00149337332667814 ...
%             -0.00228752862897723 -0.00293461428440794 -0.00336913711778552 ...
%             -0.00353984426059821 -0.00341505534277275 -0.00298663333578033 ...
%             -0.00227216878002941 -0.00131508094950306 -0.000182501201147666 ...
%             0.00103901375600469 0.00224970216283466 0.00334433532120884 ...
%             0.00422090384124832 0.00478956826522682 0.00498112788822336 ...
%             0.00475425890710489 0.00410083349277247 0.00304875325685177 ...
%             0.00166190687467261 3.70804132152861e-05 -0.00170210587268522 ...
%             -0.00341390793604009 -0.00494924985579866 -0.00616382603032522 ...
%             -0.00693058926770589 -0.00715161496169381 -0.0067683242092033 ...
%             -0.00576912397329769 -0.00419367816426356 -0.0021332510907656 ...
%             0.000273150802447967 0.00284679182646506 0.0053809936296768 ...
%             0.0076559940398333 0.00945589569447757 0.0105865043961938 ...
%             0.010892722924404 0.0102741293408896 0.00869743662315699 ...
%             0.00620470178531634 0.00291641840019339 -0.000971030169342372 ...
%             -0.00519368189074281 -0.00943377311733958 -0.0133382651492115 ...
%             -0.0165410231971227 -0.0186872373008834 -0.0194584544540114 ...
%             -0.0185964832959029 -0.0159244486064987 -0.0113634147660798 ...
%             -0.00494325816961454 0.00319316794147242 0.0127930909409835 ...
%             0.0235041237446633 0.0348913398948033 0.0464601624212192 ...
%             0.0576836896204099 0.0680327503908746 0.077006766380848 ...
%             0.0841634149106499 0.0891451428544063 0.0917007746596668 ...
%             0.0917007746596668 0.0891451428544063 0.0841634149106499 ...
%             0.077006766380848 0.0680327503908746 0.0576836896204099 ...
%             0.0464601624212192 0.0348913398948033 0.0235041237446633 ...
%             0.0127930909409835 0.00319316794147242 -0.00494325816961454 ...
%             -0.0113634147660798 -0.0159244486064987 -0.0185964832959029 ...
%             -0.0194584544540114 -0.0186872373008834 -0.0165410231971227 ...
%             -0.0133382651492115 -0.00943377311733958 -0.00519368189074281 ...
%             -0.000971030169342372 0.00291641840019339 0.00620470178531634 ...
%             0.00869743662315699 0.0102741293408896 0.010892722924404 ...
%             0.0105865043961938 0.00945589569447757 0.0076559940398333 ...
%             0.0053809936296768 0.00284679182646506 0.000273150802447967 ...
%             -0.0021332510907656 -0.00419367816426356 -0.00576912397329769 ...
%             -0.0067683242092033 -0.00715161496169381 -0.00693058926770589 ...
%             -0.00616382603032522 -0.00494924985579866 -0.00341390793604009 ...
%             -0.00170210587268522 3.70804132152861e-05 0.00166190687467261 ...
%             0.00304875325685177 0.00410083349277247 0.00475425890710489 ...
%             0.00498112788822336 0.00478956826522682 0.00422090384124832 ...
%             0.00334433532120884 0.00224970216283466 0.00103901375600469 ...
%             -0.000182501201147666 -0.00131508094950306 -0.00227216878002941 ...
%             -0.00298663333578033 -0.00341505534277275 -0.00353984426059821 ...
%             -0.00336913711778552 -0.00293461428440794 -0.00228752862897723 ...
%             -0.00149337332667814 -0.00062570074626459 0.000240354585409121 ...
%             0.00103430281594055 0.00169578050590084 0.00217888140063813 ...
%             0.00245504781556044 0.00251436889222418 0.00236527183654154 ...
%             0.00203272543946668 0.00155519104252675 0.000980645990313025 ...
%             0.000362062479165916 -0.000247252472774547 -0.000798062393553396 ...
%             -0.00124900273512674 -0.00156949968209359 -0.0017416176869983 ...
%             -0.00176074741916856 -0.0016351477096552 -0.00138444983906933 ...
%             -0.0010373125988593 -0.000628476076289571 -0.000195497257551956 ...
%             0.000224540219312118 0.000598065748433268 0.000897572696627023 ...
%             0.0011034983962935 0.00120531889489314 0.00120181752081207 ...
%             0.00110055856448703 0.0009166624199734 0.000671031290049226 ...
%             0.000388211292374284 9.40953813686163e-05 -0.000186328523872935 ...
%             -0.000430997258952 -0.000622405288952844 -0.000748739391211201 ...
%             -0.000804453788502893 -0.000790276273843455 -0.000712685076721033 ...
%             -0.000582938669408671 -0.000415773182187427 -0.00022790244705259 ...
%             -3.64629764492972e-05 0.000142459335201312 0.000295100964072654 ...
%             0.000410997280554651 0.000483602555048752 0.000510527533831792 ...
%             0.000493403723003926 0.000437415190483179 0.000350564449295843 ...
%             0.000242756981640449 0.000124798181747646 7.39676831242544e-06 ...
%             -9.97393154321195e-05 -0.000188643499140986 -0.000253616778234363 ...
%             -0.000291511640398601 -0.000301769547733039 -0.000286229952374194 ...
%             -0.000248747580313544 -0.000194668654036387 -0.000130224962972193 ...
%             -6.19069403072163e-05 4.12655718676372e-06 6.25524649174397e-05 ...
%             0.000109264579410146 0.000141608836941406 0.000158465470564327 ...
%             0.000160185359469889 0.000148400563620473 0.00012573873823221 ...
%             9.547719648086e-05 6.11745779029926e-05 2.63165145053395e-05 ...
%             -5.99315907014781e-06 -3.32714845874957e-05 -5.38105698578391e-05 ...
%             -6.6741305300701e-05 -7.20102497793814e-05 -7.02813275755504e-05 ...
%             -6.27800853369776e-05 -5.11020471573871e-05 -3.70080154888737e-05 ...
%             -2.22280907932016e-05 -8.2930464923808e-06];
    end
    properties
        radarPeaksFinderError
        
    end
    properties (Access=public)%protected)
        %radarInputFile %radar_filepath .dat
        peaksOutputFile %save_filepath .mat
        Fs
        peakThresholdAboveNoise_dB
    end
    
    
    
    methods
        function this=radarPeaksFinder(radarInputFile,radarMetaFile,Fs,peakThresholdAboveNoise_dB)
            %Verify input file exists, throw error if they do not
              if (exist(radarInputFile,'file') ~= 2)
                  ME = MException('signalDecimator:invalidFile', ...
                      'Input file does not exist! Filename:\n%s\n\n',...
                      radarInputFile);
                  throw(ME);
              else
                  this.inputFile=radarInputFile;
                  this.peaksOutputFile=[radarInputFile(1:end-length('dec01.dat')),'pksTest.mat'];
                  this=setRadarMetaFile(this,radarMetaFile);
              end          
            
            this.Fs=Fs;
            if nargin>2
                this.peakThresholdAboveNoise_dB=peakThresholdAboveNoise_dB;
            end
        end
        
        function this=initRadarPeakFinder(this)
            %radar decimated file
            this.inputIQDirection='QI';
            this.EOFAction='Rnormal';
            initialSeekSamples=0;
            this=setSeekPositionSamples(this,initialSeekSamples);
            this=setReadScale(this);
            this=initInputFile(this);
            
        end
        function this=findRadarPeaks(this)
                 Hd = dsp.FIRFilter( 'Numerator',this.filterNumerator);
                 % get radar signal time info
                 signalTime=getSignalTime(this);
                 % read radar signal and get max every 1msec
                 windowTime=1e-6;
                 windowLength=floor(windowTime*this.Fs);
                 numOfSegments=floor(signalTime.totalNumberOfSamples/windowLength);                
%                 numOfSegmentsWithLeftOver=numOfSegments;
%                  if signalTime.totalNumberOfSamples>numOfSegments*this.samplesPerSegment
%                      leftOverSamples=signalTime.totalNumberOfSamples-numOfSegments*this.samplesPerSegment;
%                  end
%                  if leftOverSamples>0
%                      numOfSegmentsWithLeftOver=numOfSegments+1;
%                  end
                 %filterRESET=false;
                 %t0=0;
                % for I=1:numOfSegmentsWithLeftOver
%                      if (I==numOfSegmentsWithLeftOver) && (numOfSegmentsWithLeftOver~=numOfSegments)
%                          this.samplesPerSegment=leftOverSamples;
%                      end
                     %read decimated radar file at once
                     this.samplesPerSegment=signalTime.totalNumberOfSamples;
                     sigMeas =readSamples(this);
                     %this=seekNextPositionSamples(this);
                     %filter data with 1MHz filter
                     sigMeas=Hd(sigMeas);
                     % Reshape to every microsecond & get max
                     sigMeasReshape=abs(reshape(sigMeas,[windowLength,numOfSegments])); clear sigMeas;
                     sigMeasReshapeMaxSegments=max(sigMeasReshape,[],1);clear sigMeasReshape;
                     % find peaks with min peak distance
                     tx=(0:(numOfSegments-1))*windowTime;
                     MinPeakDistance=3.5;
                     %figure;findpeaks(Data_Max_Segments,tx,'MinPeakDistance',MinPeakDistance)
                     [pks,locs]=findpeaks(sigMeasReshapeMaxSegments,tx,'MinPeakDistance',MinPeakDistance);
                     % data_size_postfilter=size(Data_Reshape_abs);
                     
                     if ~isempty(this.peakThresholdAboveNoise_dB)
                         radarPeaks.pks=pks;
                         radarPeaks.locs=locs;
                         [this,sigmaW2,medianPeak,noiseEst,maxPeak,maxPeakLoc]=estimateRadarNoise(this,this.Fs,radarPeaks);
                         pksIndx=((pow2db(pks.^2)-pow2db(sigmaW2))>this.peakThresholdAboveNoise_dB);
                         pks=pks(pksIndx);
                         locs=locs(pksIndx);
                     end
                     
                     %save(this.peaksOutputFile,'tx','sigMeasReshapeMaxSegments','pks','locs');
                     save(this.peaksOutputFile,'pks','locs');
                     
                     
                     %%
                     %t=((0:this.samplesPerSegment-1).')*(1/this.oldFs)+t0;
                     
                     %sigMeasShifted=sigMeas.*exp(-1i*2*pi*(this.freqShift)*t);
                     %[sigResampled,~]=dspFun.resampleFilt(sigMeasShifted,this.oldFs,this.newFs,filterRESET,this.filterSpec);
                     %writeSamples(this,sigResampled);
                     %t0=t(end)+1/this.oldFs;
                     
%                      testVar(I,1)=length(sigMeas);
%                      testVar(I,2)=length(t);
%                      testVar(I,3)=length(sigMeasShifted);
%                      testVar(I,4)=length(sigResampled);
%                 end
%                  save([this.outputFile,'Vars.mat'],'testVar','signalTime','numOfSegments','numOfSegmentsWithLeftOver',...
%                      'leftOverSamples');
        
        
%     %% 
% 	%Rf_gain=this_RFgain;
%     
%     Ts=1/Fs;
%     windowLength=floor(windowTime/Ts);
%     windowTime=windowLength*Ts; %corrected windowTime in case of no integer multiples of Ts 
%     overLapSampleNo=0;
%     fileInfo=dir(radar_filepath);
%     
%     samplesPerSegment=windowLength;
%     TotalNSamples=fileInfo.bytes/4;
%     NumSeg=floor(TotalNSamples/(samplesPerSegment-overLapSampleNo));
%     leftOver=TotalNSamples-NumSeg*samplesPerSegment;
%     if leftOver>0
%         NumSeg=NumSeg+1;
%     end
% 
%     seekPosition=0;
% 
% 	%% 
%     [~, Data_Vector_c] = radar_data_reader(radar_filepath,seekPosition,TotalNSamples);
%     Data_Vector_c_gain=Rf_gain*Data_Vector_c; clear Data_Vector_c;
%     
%     %DEBUGGING
%     data_size_prefilter=size(Data_Vector_c_gain); 
%     
%     %% Apply 2 MHz filter
%     
%     Data_Vector_filt = step(Hd,Data_Vector_c_gain); clear Data_Vector_c_gain;
%     
%     %% Reshape to every microsecond & report peak
%     Data_Reshape=reshape(Data_Vector_filt,[samplesPerSegment,NumSeg]); clear Data_Vector_filt;
%     Data_Reshape_abs=abs(Data_Reshape);clear Data_Reshape;
%     Data_Max_Segments=max(Data_Reshape_abs,[],1);
% 
%     %%
%     tx=(0:(NumSeg-1))*windowTime;
%     MinPeakDistance=3.5;
%     figure;findpeaks(Data_Max_Segments,tx,'MinPeakDistance',MinPeakDistance)
%     [pks,locs]=findpeaks(Data_Max_Segments,tx,'MinPeakDistance',MinPeakDistance);
%     %pks=find(pks_all>peaks_threshold);
%     %locs=locs_all(find(pks==pks);
%     %%
%     %DEBUGGING
%     data_size_postfilter=size(Data_Reshape_abs);
%     save(save_filepath,'tx','Data_Max_Segments','pks','locs','data_size_prefilter','data_size_postfilter')
        
        end
        
        
        function this=resetRadarPeaksFinder(this)
            this=resetSignalFromFile(this);
        end
        
    end
    
end
