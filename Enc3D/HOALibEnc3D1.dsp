declare name "HOALibEnc3D1";
declare title "High Order Ambisonics library";
declare author "Pierre Guillot, Eliott Paris";
declare copyright "2012-2015 Guillot, Paris, CICM, Labex Arts H2H, U. Paris 8";
import("math.lib");

process(x) = HoaEncoder3D(1, x, azi, elev);

azi = hslider("[1]azi[unit:rad]", 0,  -3.1415926535898 , 3.1415926535898  , 0.0000001) + 3.1415926535898;
elev = hslider("[2]ele[unit:rad]", 0, -1.5707963267949 , 1.5707963267949 ,  0.0000001) * -1;

HoaEncoder3D(N, x, theta, phi) = par(i, (N+1) * (N+1), x * y(degree(i), order(i), theta, phi))
with
{
	// The degree l of the harmonic[l, m]	
	degree(index)  = int(sqrt(index));
	// The order m of the harmonic[l, m]	
	order(index)   = int(index - int(degree(index) * int(degree(index) + 1)));

	// The spherical harmonics
	y(l, m, theta, phi) =  e(m, theta) * k(l, m) * p(l, m, cos(phi + PI * 0.5))
	with
	{	
		// The associated Legendre polynomial
		// If l = 0   => p = 1
		// If l = m   => p = -1 * (2 * (l-1) + 1) * sqrt(1 - cphi*cphi) * p(l-1, l-1, cphi)
		// If l = m+1 => p = phi * (2 * (l-1) + 1) * p(l-1, l-1, cphi)
		// Else => p = (cphi * (2 * (l-1) + 1) * p(l-1, abs(m), cphi) - ((l-1) + abs(m)) * p(l-2, abs(m), cphi)) / ((l-1) - abs(m) + 1)
		p(l, m, cphi) = pcalcul(((l != 0) & (l == abs(m))) + ((l != 0) & (l == abs(m)+1)) * 2 + ((l != 0) & (l != abs(m)) & (l != abs(m)+1)) * 3, l, m, cphi)
		with
		{
			pcalcul(0, l, m, cphi) = 1;
			pcalcul(1, l, m, cphi) = -1 * (2 * (l-1) + 1) * sqrt(1 - cphi*cphi) * p(l-1, l-1, cphi);
			pcalcul(2, l, m, cphi) = cphi * (2 * (l-1) + 1) * p(l-1, l-1, cphi);
			pcalcul(s, l, m, cphi) = (cphi * (2 * (l-1) + 1) * p(l-1, abs(m), cphi) - ((l-1) + abs(m)) * p(l-2, abs(m), cphi)) / ((l-1) - abs(m) + 1);
		};	

		// The exponential imaginary
		// If m > 0 => e^i*m*theta = cos(m * theta)
		// If m < 0 => e^i*m*theta = sin(-m * theta)
		// If m = 0 => e^i*m*theta = 1
		e(m, theta) = ecalcul((m > 0) * 2 + (m < 0), m, theta)
		with 
		{
			ecalcul(2, m, theta) = cos(m * theta);
			ecalcul(1, m, theta) = sin(abs(m) * theta);
			ecalcul(s, m, theta) = 1;
		}; 
		
		// The normalization
		// If m  = 0 => k(l, m) = 1
		// If m != 0 => k(l, m) = sqrt((l - abs(m))! / l + abs(m))!) * sqrt(2)
		
		// k(l, m) = kcalcul((m != 0), l, m)
		// with
		// {	
		//	kcalcul(0, l, m) = 1;
		//	kcalcul(1, l, m) = sqrt(fact(l - abs(m)) / fact(l + abs(m))) * sqrt(2)
		//	with
		//	{
		//		fact(0) = 1;
		//		fact(n) = n * fact(n-1);
		//	};
		// };

		// FACTORIAL [gamma­_function]
		factorial(n) = gamma(n+1);

		// N3D NORM taken from https://github.com/sekisushai/ambitools
		k(m,n) =  sqrt((2*m+1)*factorial(m-abs(n))/factorial(m+abs(n)))*
            		case{
            		(0) => 1;
            		(n) => sqrt(2);
			}(n);	

	};
};
