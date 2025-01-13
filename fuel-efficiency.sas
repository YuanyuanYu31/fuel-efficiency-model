data auto;
length name $20.;
infile "/home/u63231041/FinalProject/mpg-output.csv" delimiter="," firstobs=1;
input mpg cylinders displacement horsepower weight acceleration year origin $ name $ ID $;
run;

proc print data = auto;
run;

proc means data=auto maxdec=3;
run;

proc corr data=auto;
run;

/* Principal Component Analysis */

proc sgscatter data=auto;
matrix mpg cylinders displacement horsepower weight acceleration; 
run;

proc sgscatter data=auto;
plot displacement*horsepower/datalabel=ID; 
run;

proc sgscatter data=auto;
plot mpg*horsepower/datalabel=ID; 
run;

proc sgscatter data=auto;
plot mpg*cylinders/datalabel=ID; 
run;

proc sgscatter data=auto;
plot mpg*weight/datalabel=ID; 
run;

proc princomp data=auto out=result_cor;
var mpg cylinders displacement horsepower weight acceleration;
run;
quit;
run;

proc print data=result_cor;
run;

proc sgplot data=result_cor;
scatter x=prin1 y=prin2/datalabel=ID;
run;
quit;

/* Factor Analysis */

/* PCA method */
title 'PCA method';
proc factor data= auto method=prin rotate=varimax;
run;

proc factor data=auto method=prin n=2 rotate=varimax;
run;

/* MLE method */
title 'MLE method';
proc factor data=auto method=ml heywood rotate=varimax;
run;


/* Discriminant Analysis */

proc sgplot data=auto;
histogram cylinders;
run;

proc sgscatter data=auto;
plot mpg*horsepower/group=cylinders;
run;

proc sgscatter data=auto;
plot mpg*displacement/group=cylinders;
run;

proc sgscatter data=auto;
plot horsepower*weight/group=cylinders;
run;

proc sgscatter data=auto;
matrix mpg horsepower displacement weight acceleration/group=cylinders diagonal=
(histogram kernel normal);
run;

proc discrim data=auto
method = normal pool=test  listerr manova;
priors prop; 
class cylinders;
var mpg horsepower displacement weight acceleration;
/*itle 'Using Linear Discriminant Function';*/
run;
quit;


/* Multivariate Regression */

/* Conduct an overall test and save the residuals */

data trans;
length name $20.;
set auto;
logmpg = log(mpg);
logwt = log(weight);
loghp = log(horsepower);
logacc = log(acceleration);
logdis = log(displacement);
run;


PROC REG data = trans;
var horsepower cylinders;
MODEL logmpg logwt = horsepower cylinders;
MTEST;
output out = rout r=res1 res2  p=pred1 pred2;
QUIT;
run;

proc print data = rout;
run;

/* Check Norms*/
%include '/home/u63231041/FinalProject/multnorm.sas';
%multnorm(data = rout, var = res1 res2,plot= mult, 
hires = yes);






proc means data = auto maxdec = 3;
class cylinders;
var mpg acceleration horsepower;
run;

proc means data = auto maxdec = 3;
class weight;
var mpg acceleration horsepower;
run;

proc sgscatter data = auto;
plot (mpg)*weight/group = cylinders markerattrs=(symbol="diamondFilled");
run;

proc sgscatter data = auto;
plot (horsepower)*weight/group = cylinders markerattrs=(symbol="diamondFilled");
run;

/*proc sgscatter data = auto;
plot (mpg)*cylinders/group = wt markerattrs=(symbol="diamondFilled");
run;*/

data auto_2;
set auto;
where (cylinders notin (3 5)); 
run;

proc print data=auto_2;
run;


PROC REG data = auto_2;
MODEL mpg acceleration horsepower = cylinders weight;
MTEST;
QUIT;
run;

/* MANOVA */
proc GLM data=auto_2;
class cylinders;
model mpg acceleration horsepower weight = cylinders/nouni;
MANOVA h = cylinders;
quit;


/* multiple linear regression */

/* backward elimination */
proc reg data=auto;
model mpg=cylinders displacement horsepower weight acceleration / selection=backward AIC;
run;









