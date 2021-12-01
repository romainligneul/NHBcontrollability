function VetSmo = smoothLNI(Vet,n)
%
% Linear Smooth Function
% Brunno Machado de Campos
% University of Campinas
%
% VetSmo = smoothLNI(Vet,n)
% Vet = vector that you want to smooth
% n = size of the moving average
% 
%
% Brunno Machado de Campos 09/10/2012
% University of Campinas

Comp = size(Vet,1);

if mod(n,2) == 0
    n = n-1;
end
 
VetSmo = zeros(Comp,1);

for i = 1:Comp
    
    if i<=((n-1)/2)
        VetSmo(i) = mean(Vet(i-(i-1):i+(i-1)));
    else if i >= (Comp - ((n-1)/2))
        VetSmo(i) = mean(Vet(i-(Comp-i):i+(Comp-i)));    
        else    
    VetSmo(i) = mean(Vet(i-((n-1)/2):i+((n-1)/2)));    
         end
    end
end
