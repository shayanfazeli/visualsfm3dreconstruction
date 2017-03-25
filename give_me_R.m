function R = give_me_R(quaternion)
w=quaternion(1);
x=quaternion(2);
y=quaternion(3);
z=quaternion(4);

n = w * w + x * x + y * y + z * z;
if n == 0
   s=0;
else
   s=2/n;
end


wx = s * w * x; wy = s * w * y; wz = s * w * z;
xx = s * x * x; xy = s * x * y; xz = s * x * z;
yy = s * y * y; yz = s * y * z; zz = s * z * z;



R=[ 1 - (yy + zz), xy - wz, xz + wy;...
    xy + wz,1 - (xx + zz),yz - wx;...
    xz - wy,yz + wx,1 - (xx + yy)];






end