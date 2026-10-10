if ~exist('porto','var')
    porto = serialport("COM7", 115200);
    porto.Timeout = 1;
    configureTerminator(porto,"CR/LF")
    writeline(porto,"0");
end
pause(2); % Aparentemente, precisa de algum tempo antes de se poder utilizar o objeto :(

num_samples = 10;
samples=zeros(1,num_samples);
for i=1:10
    try
        samples(i)=str2double(writeread(porto,"1"));
    catch
        samples(i)=-1;
    end
end
disp("Collected Samples: ");
disp(samples);

clear porto;
