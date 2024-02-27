function val=CheckInput(h,minval,maxval,altval)

val=str2num(get(h,'String'));

if length(val)==0 | val<minval | val>maxval
    set(h,'BackgroundColor',[1 0 0]);
    val=altval;
else
    set(h,'BackgroundColor',[1 1 1]);
end
