classdef (StrictDefaults)voiceActivityDetector2 < matlab.System & ...
        matlab.system.mixin.Propagates
%voiceActivityDetector Detect presence of speech in audio signal
%   VAD = voiceActivityDetector returns a System object, VAD, that
%   implements a voice activity detector. The object detects presence of
%   speech independently across each input channel over time using the
%   specifications.
%
%   VAD = voiceActivityDetector('Name', Value, ...) returns a voice
%   activity detector System object, VAD, with each specified property name
%   set to the specified value. You can specify additional name-value pair
%   arguments in any order as (Name1,Value1,...,NameN, ValueN).
%
%   Step method syntax:
%
%   [P, N] = step(VAD,X) applies a voice activity detector on the input X,
%   and returns the probability that speech is present, P. It also returns
%   the estimated noise variance per frequency bin in N. X must either be a
%   real-valued time domain or complex-valued frequency domain
%   double-precision or single-precision matrix. The object treats each
%   column as an independent channel.
%
%   System objects may be called directly like a function instead of using
%   the step method. For example, y = step(obj, x) and y = obj(x) are
%   equivalent.
%
%   voiceActivityDetector methods:
%
%   step        - See above description for use of this method
%   release     - Allow property value and input characteristics to change
%   clone       - Create voiceActivityDetector object with same property
%                 values
%   isLocked    - Locked status (logical)
%   <a href="matlab:help matlab.System/reset   ">reset</a>       - Reset the internal states to initial conditions
%
%   voiceActivityDetector properties:
%
%   InputDomain                - Domain of input signal
%   FFTLength                  - FFT length
%   Window                     - Window function for FFT
%   SidelobeAttenuation        - Sidelobe attenuation of window (dB)
%   SilenceToSpeechProbability - Probability of transition from a frame of
%                                silence to a frame of speech
%   SpeechToSilenceProbability - Probability of transition from a frame of
%                                speech to a frame of silence
%
%   % EXAMPLE
%   % Use a VAD to detect presence of speech in an audio signal. Plot the
%   % probability of speech presence along with the audio samples.
%
%   % Audio file reader to read a speech file
%   afr = dsp.AudioFileReader('Counting-16-44p1-mono-15secs.wav');
%   fs = afr.SampleRate;
%   
%   % Audio frames will be of 20 ms duration, with 75% overlap between
%   % successive frames
%   frameSize = ceil(20e-3*fs);
%   overlapSize = ceil(0.75*frameSize);
%   hopSize = frameSize-overlapSize;
%   afr.SamplesPerFrame = hopSize;
%   
%   % VAD to detect the presence of speech
%   vad = voiceActivityDetector('FFTLength', 1024);
%   
%   % Input buffer to manage overlapping between audio frames
%   inputBuffer = dsp.AsyncBuffer('Capacity', frameSize);
%   
%   % Scope to plot the audio signal and corresponding probability of speech
%   % presence as detected by the VAD
%   scope = dsp.TimeScope('NumInputPorts',2,'SampleRate',fs,...
%       'TimeSpan',3,'BufferLength',3*fs,'YLimits',[-1.5,1.5],...
%       'TimeSpanOverrunAction','Scroll','ShowLegend',true,...
%       'ChannelNames',{'Audio','Probability of presence of speech'});
%   
%   % Audio device writer to play the audio through sound card
%   player = audioDeviceWriter('SampleRate', fs);
%   
%   pHold = ones(hopSize, 1);
%   while ~isDone(afr)
%       % Read from audio file and save the samples into an input buffer
%       x = afr();
%       n = write(inputBuffer, x);
%       
%       % Read a frame from the buffer with specified overlap from the previous
%       % frame
%       overlappedInput = read(inputBuffer, frameSize, overlapSize);
%       
%       % Get the probability of speech presence
%       p = vad(overlappedInput);
%       
%       % Hold the probability value for the length of the new samples. This
%       % makes sure that the audio plot is consistent with the plot of speech
%       % presence probability
%       pHold(end) = p;
%       scope(x, pHold);
%       
%       % Play the audio through sound card
%       player(x);
%       
%       % Save the result for plotting the next time
%       pHold(:) = p;
%   end
%   release(player);
%
%   See also pitch, mfcc, cepstralFeatureExtractor

% Copyright 2017 The MathWorks, Inc.
    
%#codegen
    properties (Nontunable)
        %InputDomain Domain of the input
        %   Specify the domain of the input to the voice activity detector,
        %   as one of 'Time' or 'Frequency'. The default value of this
        %   property is 'Time'.
        InputDomain = 'Time';
        %FFTLength FFT length
        %  Specify the FFT length as a positive scalar integer. The default
        %  value of this property is [], which means that the FFT length is
        %  equal to the number of rows in the input. This property applies
        %  when InputDomain is 'Time'.
        FFTLength = [];
        %Window Window function
        %  Specify a window function for the FFT as one of 'Rectangular' |
        %  'Chebyshev' | 'Flat Top' | 'Hamming' | 'Hann' | 'Kaiser'. This
        %  property applies when InputDomain is 'Time'. The default value
        %  of this property is 'Hann'.
        Window = 'Hann';
        %SidelobeAttenuation Sidelobe attenuation of the window (dB)
        %  Specify the sidelobe attenuation of the window as a real,
        %  positive scalar in decibels (dB). This property applies when
        %  InputDomain is 'Time' and Window is 'Chebyshev' or 'Kaiser'. The
        %  default of this property is 60 dB.
        SidelobeAttenuation = 60;
    end
    
    properties
        %SilenceToSpeechProbability Probability of transition from a frame 
        %                           of silence to a frame of speech
        %   Specify the probability of transition from a frame of silence
        %   to a frame of speech, as a finite non-negative real scalar
        %   between 0 and 1. This is used by a first-order Markov process
        %   to improve the prediction of the VAD especially to prevent
        %   clipping of weak speech tails. The default value of this
        %   property is 0.2. This property is tunable.
        SilenceToSpeechProbability = 0.2
        %SpeechToSilenceProbability Probability of transition from a frame 
        %                           of speech to a frame of silence
        %   Specify the probability of transition from a frame of speech to
        %   a frame of silence, as a finite non-negative real scalar
        %   between 0 and 1. This is used by a first-order Markov process
        %   to improve the prediction of the VAD especially to prevent
        %   clipping of weak speech tails. The default value of this
        %   property is 0.1. This property is tunable.
        SpeechToSilenceProbability = 0.1
    end
    
    properties(Constant, Hidden)
        InputDomainSet = matlab.system.StringSet( {'Time', 'Frequency'} );
        WindowSet = matlab.system.StringSet({...
            'Chebyshev', ...
            'Flat Top', ...
            'Hamming', ...
            'Hann', ...
            'Kaiser',...
            'Rectangular'});
    end
    
    properties(Access=protected, Nontunable)
        pVAD
        pWindow
        pInputDT
        pFFTLength
    end

    methods
        function obj = voiceActivityDetector(varargin)
            setProperties(obj,nargin,varargin{:})
        end
        %------------------------------------------------------------------
        % Set methods
        function set.FFTLength(obj, val)
            if isempty(val)
                validateattributes(val, {'numeric'},{},...
                    'set.FFTLength','FFTLength');
            else
                validateattributes(val, {'numeric'}, ...
                    {'finite','real','scalar','integer','positive'},...
                    'set.FFTLength','FFTLength');
            end
            obj.FFTLength = val;
        end
        function set.SidelobeAttenuation(obj, val)
            validateattributes(val, {'single','double'}, ...
                              {'finite','real','scalar','positive'},...
                               'set.SidelobeAttenuation','SidelobeAttenuation'); 
            obj.SidelobeAttenuation = val;
        end
        function set.SilenceToSpeechProbability(obj, val)
            validateattributes(val, {'single','double'}, ...
                              {'real','scalar','nonnegative','<=',1},...
                               'set.SilenceToSpeechProbability','SilenceToSpeechProbability'); 
            obj.SilenceToSpeechProbability = val;
        end
        function set.SpeechToSilenceProbability(obj, val)
            validateattributes(val, {'single','double'}, ...
                              {'real','scalar','nonnegative','<=',1},...
                               'set.SpeechToSilenceProbability','SpeechToSilenceProbability'); 
            obj.SpeechToSilenceProbability = val;
        end
    end

    methods(Access = protected)        
        function setupImpl(obj,x)
            [frameSize, numChannels] = size(x);
            obj.pInputDT = class(x);
            dt = obj.pInputDT;
            
            obj.pVAD = audio.internal.SohnVAD( ...
                'SilenceToSpeechProbability',cast(obj.SilenceToSpeechProbability,dt),...
                'SpeechToSilenceProbability',cast(obj.SpeechToSilenceProbability,dt));

            coder.extrinsic('dsp.private.designWindow');
            if strcmp(obj.InputDomain,'Time')
                if isempty(getFFTLength(obj))
                    obj.pFFTLength = frameSize;
                else
                    coder.internal.errorIf(obj.FFTLength < frameSize, ...
                        'audio:vad:InvalidFFTLength','FFTLength');
                    obj.pFFTLength = obj.FFTLength;
                end
                setup(obj.pVAD, complex(zeros(obj.pFFTLength, numChannels, dt)));
                
                % Initialize window vector
                switch obj.Window
                    case 'Rectangular'
                        windowType = 1;
                    case 'Hann'
                        windowType = 2;
                    case 'Hamming'
                        windowType = 3;
                    case  'Flat Top'
                        windowType = 4;
                    case 'Chebyshev'
                        windowType = 5;
                    otherwise % case  'Kaiser'
                        windowType = 6;
                end
                win =  coder.const(@dsp.private.designWindow, ...
                    windowType, frameSize, dt, obj.SidelobeAttenuation);
                obj.pWindow = repmat(win,1,numChannels);  
            else
                setup(obj.pVAD, x);
            end
        end
        %------------------------------------------------------------------    
        function N = getFFTLength(obj)
            N = obj.FFTLength;
        end
        %------------------------------------------------------------------      
        function [probSpeech, noiseEstimate] = stepImpl(obj,x)
            if strcmp(obj.InputDomain,'Time')
                X = complex(dct(obj.pWindow.*x,obj.pFFTLength,1));
                [probSpeech, noiseEstimate] = step(obj.pVAD,X);
            else
                [probSpeech, noiseEstimate] = step(obj.pVAD,x);
            end
        end
        %------------------------------------------------------------------
        function resetImpl(obj)
            reset(obj.pVAD);
        end
        %------------------------------------------------------------------
        function releaseImpl(obj)
            release(obj.pVAD);
        end
        %------------------------------------------------------------------
        function processTunedPropertiesImpl(obj)
            dt = obj.pInputDT;
            obj.pVAD.SilenceToSpeechProbability = cast(obj.SilenceToSpeechProbability,dt);
            obj.pVAD.SpeechToSilenceProbability = cast(obj.SpeechToSilenceProbability,dt);
        end
        %------------------------------------------------------------------
        function flag = isInactivePropertyImpl(obj,prop)
            flag = false;
            switch prop
                case {'Window','FFTLength'}
                    flag = strcmp(obj.InputDomain, 'Frequency');
                case 'SidelobeAttenuation'
                    flag = strcmp(obj.InputDomain, 'Frequency') || ...
                        (~strcmp('Chebyshev',obj.Window) && ...
                        ~strcmp('Kaiser',obj.Window));
            end
        end
        %------------------------------------------------------------------
        function validateInputsImpl(obj,u)
            % Input must be floating-point and 2-D.
            if strcmp(obj.InputDomain, 'Time')
                validateattributes(u, {'single', 'double'}, {'2d','real'},'','');
            else
                validateattributes(u, {'single', 'double'}, {'2d'},'','');
            end
        end
        %------------------------------------------------------------------
        function flag = isInputComplexityLockedImpl(~,~)
            flag = false;
        end
        %------------------------------------------------------------------
        function flag = isInputSizeLockedImpl(~,~)
            flag = true;
        end
        %------------------------------------------------------------------
        function loadObjectImpl(obj,s,wasLocked)
            % Set properties in object obj to values in structure s

            % Set private and protected properties
            if wasLocked
                obj.pVAD = matlab.System.loadObject(s.pVAD);
                obj.pWindow = s.pWindow;
                obj.pFFTLength = s.pFFTLength;
                obj.pInputDT = s.pInputDT;
            end

            % Set public properties and states
            loadObjectImpl@matlab.System(obj,s,wasLocked);
        end
        %------------------------------------------------------------------
        function s = saveObjectImpl(obj)
            % Set properties in structure s to values in object obj

            % Set public properties and states
            s = saveObjectImpl@matlab.System(obj);

            % Set private and protected properties
            if isLocked(obj)
                s.pVAD = matlab.System.saveObject(obj.pVAD);
                s.pWindow = obj.pWindow;
                s.pFFTLength = obj.pFFTLength;
                s.pInputDT = obj.pInputDT;
            end
        end
        %------------------------------------------------------------------
        % Propagators
        function varargout = isOutputComplexImpl(~)
            varargout{1} = false;
            varargout{2} = false;
        end
        
        function varargout = getOutputSizeImpl(obj)
            inputSize = propagatedInputSize(obj, 1);
            varargout{1}  = [1,inputSize(2)];
            if (strcmp(obj.InputDomain, 'Time') && ~isempty(obj.FFTLength))
                varargout{2}  = [obj.FFTLength, inputSize(2)];
            else
                varargout{2}  = inputSize;
            end
        end
        
        function varargout = getOutputDataTypeImpl(obj)
            varargout{1} = propagatedInputDataType(obj, 1);
            varargout{2} = propagatedInputDataType(obj, 1);
        end
        
        function varargout = isOutputFixedSizeImpl(~)
            varargout{1} = true;
            varargout{2} = true;
        end
    end
    %----------------------------------------------------------------------
    % Static protected Methods
    %----------------------------------------------------------------------
    methods(Static, Access = protected)
        function group = getPropertyGroupsImpl
            group = matlab.system.display.Section('Title', getString(message('dsp:system:Shared:Parameters')), ...
                'PropertyList', {'InputDomain', 'Window', 'SidelobeAttenuation', 'FFTLength',...
                'SilenceToSpeechProbability', 'SpeechToSilenceProbability'});
        end
    end
end
