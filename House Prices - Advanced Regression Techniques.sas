libname mydata "/folders/myfolders";

proc import datafile="/folders/myfolders/House-Price-Advanced-Regression-Train.csv"	
	dbms=csv out=mydata.house replace;  run;
* NA's generate errors upon importing, appropriately receive the . missing operator;
    

*Bucket the data by variable type;    
data ordinal; 
set mydata.house;
keep BsmtQual BsmtCond BsmtExposure HeatingQC KitchenQual GarageQual GarageCond
     OverallQual OverallCond ExterQual ExterCond;
run;
                
data nominal;
set mydata.house;
keep MSSubClass MSZoning LotShape LandContour Utilities LotConfig LandSlope
	 Neighborhood Condition1 Condition2 BldgType HouseStyle RoofStyle RoofMatl
	 Heating Exterior1st Exterior2nd MasVnrType Foundation Electrical Functional
	 GarageType GarageFinish PavedDrive SaleType SaleCondition BsmtFinType2 BsmtFinType1
	 Street CentralAir;   
run;

data discrete;
set mydata.house;
keep BsmtFullBath BsmtHalfBath FullBath HalfBath BedroomAbvGr
     KitchenAbvGr TotRmsAbvGrd Fireplaces GarageCars;
run;                

data continuous;
set mydata.house;
keep LotFrontage LotArea MasVnrArea BsmtFinSF1 TotalBsmtSF _1stFlrSF
     _2ndFlrSF LowQualFinSF GrLivArea GarageArea WoodDeckSF OpenPorchSF
     EnclosedPorch _3SsnPorch ScreenPorch PoolArea MiscVal;
run;

data date;
set mydata.house;
keep YearBuilt YearRemodAdd GarageYrBlt MoSold YrSold;
run;


*Label encode ordinal variables;
data ordinal_encoded; 
set ordinal; 
array ordinal BsmtQual BsmtCond HeatingQC KitchenQual GarageQual GarageCond
      ExterQual ExterCond; *no need to label encode (OverallQual, OverallCond) which are already encoded;
do over ordinal; 
if ordinal = 'Ex' then ordinal = 5;
else if ordinal = 'Gd' then ordinal = 4;
else if ordinal = 'TA' then ordinal = 3;
else if ordinal = 'Fa' then ordinal = 2;
else if ordinal = 'Po' then ordinal = 1;
else if ordinal = 'NA' then ordinal = 0;
else if missing(ordinal) then ordinal = .;
else ordinal = 'ERROR';
end; 
run;

data ordinal_encoded;
set ordinal_encoded;
if BsmtExposure = 'Gd' then BsmtExposure = 4;
else if BsmtExposure = 'Av' then BsmtExposure = 3;
else if BsmtExposure = 'Mn' then BsmtExposure = 2;
else if BsmtExposure = 'No' then BsmtExposure = 1;
else if BsmtExposure = 'NA' then BsmtExposure = 0;
else if missing(BsmtExposure) then BsmtExposure = .;
else BsmtExposure = 'ERROR';
run;

*Frequencies label-encoded variables to check if values were properly encoded;
proc freq data = ordinal_encoded; run;

proc contents data = continuous ; run;
proc contents data = discrete ; run ;

*Ordinal NA's were converted to 0.  One continuous variable (LotFrontage) is chr b/c it has 'NA' values instead of . ;
data numeric_ordinal_encoded;
merge discrete continuous ordinal_encoded;
if LotFrontage = 'NA' then LotFrontage = .;
run;


*Convert character variables to numeric (you can't convert variable types in sas - you have to create new variables;
data mydata.numeric_ordinal_encoded (rename=
(BsmtCond2=BsmtCond BsmtExposure2=BsmtExposure BsmtQual2=BsmtQual ExterCond2=ExterCond ExterQual2=ExterQual
GarageCond2=GarageCond GarageQual2=GarageQual HeatingQC2=HeatingQC KitchenQual2=KitchenQual LotFrontage2=LotFrontage)); 
set numeric_ordinal_encoded;
BsmtCond2 = input(BsmtCond, 8.);
BsmtExposure2 = input(BsmtExposure, 8.);
BsmtQual2 = input(BsmtQual, 8.);
ExterCond2 = input(ExterCond, 8.);
ExterQual2 = input(ExterQual, 8.);
GarageCond2 = input(GarageCond, 8.);
GarageQual2 = input(GarageQual, 8.);
HeatingQC2 = input(HeatingQC, 8.);
KitchenQual2 = input(KitchenQual, 8.);
LotFrontage2 = input(LotFrontage, 8.);
drop BsmtCond BsmtExposure BsmtQual ExterCond ExterQual GarageCond GarageQual HeatingQC KitchenQual LotFrontage;
run;

*Verify that all numerics have been converted to numeric (from chr).  We can now use them in proc corr;
proc contents data = numeric_ordinal_encoded; run;


*Correlations;
proc corr data = numeric_ordinal_encoded out=corrcoeff(where=(_type_='CORR')); run; *corrcoef is a table of just corrs;



*Nominal "Correlations" -> Calculate mean SalePrice for each nominal level;
proc means data=mydata.house mean; class MSSubClass; var SalePrice; run;
proc means data=mydata.house mean; class MSZoning; var SalePrice; run;
proc means data=mydata.house mean; class LotShape; var SalePrice; run;
proc means data=mydata.house mean; class Utilities; var SalePrice; run;
proc means data=mydata.house mean; class LotConfig; var SalePrice; run;
proc means data=mydata.house mean; class LandSlope; var SalePrice; run;
proc means data=mydata.house mean; class Neighborhood; var SalePrice; run;
proc means data=mydata.house mean; class Condition1; var SalePrice; run;
proc means data=mydata.house mean; class Condition2; var SalePrice; run;
proc means data=mydata.house mean; class BldgType; var SalePrice; run;
proc means data=mydata.house mean; class HouseStyle; var SalePrice; run;
proc means data=mydata.house mean; class RoofStyle; var SalePrice; run;
proc means data=mydata.house mean; class RoofMatl; var SalePrice; run;
proc means data=mydata.house mean; class Heating; var SalePrice; run;
proc means data=mydata.house mean; class Exterior1st; var SalePrice; run;
proc means data=mydata.house mean; class Exterior2nd; var SalePrice; run;
proc means data=mydata.house mean; class MasVnrType; var SalePrice; run;
proc means data=mydata.house mean; class Foundation; var SalePrice; run;
proc means data=mydata.house mean; class Electrical; var SalePrice; run;
proc means data=mydata.house mean; class Functional; var SalePrice; run;
proc means data=mydata.house mean; class GarageType; var SalePrice; run;
proc means data=mydata.house mean; class GarageFinish; var SalePrice; run;
proc means data=mydata.house mean; class PavedDrive; var SalePrice; run;
proc means data=mydata.house mean; class SaleCondition; var SalePrice; run;
proc means data=mydata.house mean; class SaleType; var SalePrice; run;
proc means data=mydata.house mean; class BsmtFinType2; var SalePrice; run;
proc means data=mydata.house mean; class BsmtFinType1; var SalePrice; run;
proc means data=mydata.house mean; class Street; var SalePrice; run;
proc means data=mydata.house mean; class CentralAir; var SalePrice; run;


*Histograms;
proc univariate data=numeric_ordinal_encoded noprint; histogram 
	BsmtQual BsmtCond BsmtExposure HeatingQC KitchenQual GarageQual GarageCond
	OverallQual OverallCond ExterQual ExterCond BsmtFullBath BsmtHalfBath FullBath 
	HalfBath BedroomAbvGr KitchenAbvGr TotRmsAbvGrd Fireplaces GarageCars 
	LotFrontage LotArea MasVnrArea BsmtFinSF1 TotalBsmtSF _1stFlrSF
    _2ndFlrSF LowQualFinSF GrLivArea GarageArea WoodDeckSF OpenPorchSF
    EnclosedPorch _3SsnPorch ScreenPorch PoolArea MiscVal; run;
    
*One-Hot Encode the Nominal Data;
proc logistic
     data = mydata.house
          noprint
          outdesign = mydata.nominal_dummies2;
     class 
     MSSubClass MSZoning LotShape LandContour Utilities LotConfig LandSlope
	 Neighborhood Condition1 Condition2 BldgType HouseStyle RoofStyle RoofMatl
	 Heating Exterior1st Exterior2nd MasVnrType Foundation Electrical Functional
	 GarageType GarageFinish PavedDrive SaleType SaleCondition BsmtFinType2 BsmtFinType1
	 Street CentralAir/ param = glm;
     model SalePrice = 
     MSSubClass MSZoning LotShape LandContour Utilities LotConfig LandSlope
	 Neighborhood Condition1 Condition2 BldgType HouseStyle RoofStyle RoofMatl
	 Heating Exterior1st Exterior2nd MasVnrType Foundation Electrical Functional
	 GarageType GarageFinish PavedDrive SaleType SaleCondition BsmtFinType2 BsmtFinType1
	 Street CentralAir;
run;

data saleprice; set mydata.house; keep saleprice; run;
data mydata.nominal_dummies; set mydata.nominal_dummies2; drop SalePrice Intercept; run;
data mydata.house_final; merge mydata.nominal_dummies mydata.numeric_ordinal_encoded mydata.date saleprice; run;



*Split data into train/test splits;
proc surveyselect data=mydata.house_final outall method=srs samprate = .7 seed=2
	out=subsets; run;
data train;
   set subsets;
   if selected=1; run;
data test; 
   set subsets;
   if selected=0; run;


*Mean Imputting Missing Variables;
proc means data=train NMISS N; run; *Missing nominals received their own columns;
proc means data=train mean; var MasVnrArea;  run;
proc means data=train mean; var LotFrontage; run; 

data train_imp;
set train;
IMP_MasVnrArea = MasVnrArea  ; m_MasVnrArea=0;
IMP_LotFrontage = LotFrontage; m_LotFrontage=0;
IMP_GarageYrBlt = GarageYrBlt; m_GarageYrBlt=0;
if missing(Imp_MasVnrArea) then do; IMP_MasVnrArea=103; m_MasVnrArea = 1;  end;
if missing(LotFrontage)    then do; IMP_LotFrontage=60; m_LotFrontage = 1; end;
if missing(GarageYrBlt)    then do; IMP_GarageYrBlt=60; m_GarageYrBlt = 1; end;
run;

proc means data=train_imp NMISS N; run;

*create new train with original vars with missings have been replaced by imputed vars;
data train_imp;
set train_imp;
drop MasVnrArea LotFrontage GarageYrBlt Selected SalePrice;
rename IMP_MasVnrArea = MasVnrArea;
rename IMP_LotFrontage = LotFrontage;
rename IMP_GarageYrBlt = GarageYrBlt;
run;


*reorder train vars to place Saleprice at the end so I don't reference it in building models when doing var1--var_end;
data train_imp;
retain MSSubClass20	MSSubClass30	MSSubClass40	MSSubClass45	MSSubClass50	MSSubClass60	MSSubClass70	MSSubClass75	MSSubClass80	MSSubClass85	MSSubClass90	MSSubClass120	MSSubClass160	MSSubClass180	MSSubClass190	MSZoningC	MSZoningFV	MSZoningRH	MSZoningRL	MSZoningRM	LotShapeIR1	LotShapeIR2	LotShapeIR3	LotShapeReg	LandContourBnk	LandContourHLS	LandContourLow	LandContourLvl	UtilitiesAllPub	UtilitiesNoSeWa	LotConfigCorner	LotConfigCulDSac	LotConfigFR2	LotConfigFR3	LotConfigInside	LandSlopeGtl	LandSlopeMod	LandSlopeSev	NeighborhoodBlmngtn	NeighborhoodBlueste	NeighborhoodBrDale	NeighborhoodBrkSide	NeighborhoodClearCr	NeighborhoodCollgCr	NeighborhoodCrawfor	NeighborhoodEdwards	NeighborhoodGilbert	NeighborhoodIDOTRR	NeighborhoodMeadowV	NeighborhoodMitchel	NeighborhoodNAmes	NeighborhoodNPkVill	NeighborhoodNWAmes	NeighborhoodNoRidge	NeighborhoodNridgHt	NeighborhoodOldTown	NeighborhoodSWISU	NeighborhoodSawyer	NeighborhoodSawyerW	NeighborhoodSomerst	NeighborhoodStoneBr	NeighborhoodTimber	NeighborhoodVeenker	Condition1Artery	Condition1Feedr	Condition1Norm	Condition1PosA	Condition1PosN	Condition1RRAe	Condition1RRAn	Condition1RRNe	Condition1RRNn	Condition2Artery	Condition2Feedr	Condition2Norm	Condition2PosA	Condition2PosN	Condition2RRAe	Condition2RRAn	Condition2RRNn	BldgType1Fam	BldgType2fmCon	BldgTypeDuplex	BldgTypeTwnhs	BldgTypeTwnhsE	HouseStyle1_5Fin	HouseStyle1_5Unf	HouseStyle1Story	HouseStyle2_5Fin	HouseStyle2_5Unf	HouseStyle2Story	HouseStyleSFoyer	HouseStyleSLvl	RoofStyleFlat	RoofStyleGable	RoofStyleGambr	RoofStyleHip	RoofStyleMansa	RoofStyleShed	RoofMatlClyTile	RoofMatlCompShg	RoofMatlMembran	RoofMatlMetal	RoofMatlRoll	RoofMatlTar_Grv	RoofMatlWdShake	RoofMatlWdShngl	HeatingFloo	HeatingGasA	HeatingGasW	HeatingGrav	HeatingOthW	HeatingWall	Exterior1stAsbShng	Exterior1stAsphShn	Exterior1stBrkComm	Exterior1stBrkFace	Exterior1stCBlock	Exterior1stCemntBd	Exterior1stHdBoard	Exterior1stImStucc	Exterior1stMetalSd	Exterior1stPlywood	Exterior1stStone	Exterior1stStucco	Exterior1stVinylSd	Exterior1stWd_Sdng	Exterior1stWdShing	Exterior2ndAsbShng	Exterior2ndAsphShn	Exterior2ndBrk_Cmn	Exterior2ndBrkFace	Exterior2ndCBlock	Exterior2ndCmentBd	Exterior2ndHdBoard	Exterior2ndImStucc	Exterior2ndMetalSd	Exterior2ndOther	Exterior2ndPlywood	Exterior2ndStone	Exterior2ndStucco	Exterior2ndVinylSd	Exterior2ndWd_Sdng	Exterior2ndWd_Shng	MasVnrTypeBrkCmn	MasVnrTypeBrkFace	MasVnrTypeNA	MasVnrTypeNone	MasVnrTypeStone	FoundationBrkTil	FoundationCBlock	FoundationPConc	FoundationSlab	FoundationStone	FoundationWood	ElectricalFuseA	ElectricalFuseF	ElectricalFuseP	ElectricalMix	ElectricalNA	ElectricalSBrkr	FunctionalMaj1	FunctionalMaj2	FunctionalMin1	FunctionalMin2	FunctionalMod	FunctionalSev	FunctionalTyp	GarageType2Types	GarageTypeAttchd	GarageTypeBasment	GarageTypeBuiltIn	GarageTypeCarPort	GarageTypeDetchd	GarageTypeNA	GarageFinishFin	GarageFinishNA	GarageFinishRFn	GarageFinishUnf	PavedDriveN	PavedDriveP	PavedDriveY	SaleTypeCOD	SaleTypeCWD	SaleTypeCon	SaleTypeNew	SaleTypeOth	SaleTypeWD	SaleConditionAbnorml	SaleConditionAdjLand	SaleConditionAlloca	SaleConditionFamily	SaleConditionNormal	SaleConditionPartial	BsmtFinType2ALQ	BsmtFinType2BLQ	BsmtFinType2GLQ	BsmtFinType2LwQ	BsmtFinType2NA	BsmtFinType2Rec	BsmtFinType2Unf	BsmtFinType1ALQ	BsmtFinType1BLQ	BsmtFinType1GLQ	BsmtFinType1LwQ	BsmtFinType1NA	BsmtFinType1Rec	BsmtFinType1Unf	StreetGrvl	StreetPave	CentralAirN	CentralAirY	BsmtFullBath	BsmtHalfBath	FullBath	HalfBath	BedroomAbvGr	KitchenAbvGr	TotRmsAbvGrd	Fireplaces	GarageCars	LotArea	BsmtFinSF1	TotalBsmtSF	_1stFlrSF	_2ndFlrSF	LowQualFinSF	GrLivArea	GarageArea	WoodDeckSF	OpenPorchSF	EnclosedPorch	_3SsnPorch	ScreenPorch	PoolArea	MiscVal	OverallQual	OverallCond	BsmtCond	BsmtExposure	BsmtQual	ExterCond	ExterQual	GarageCond	GarageQual	HeatingQC	KitchenQual	MasVnrArea	m_MasVnrArea	LotFrontage	m_LotFrontage	SalePrice
; set train_imp; run;



*create test set with original vars with missings having been replaced by same imputed values in train data;
proc means data=test NMISS N; run;
proc means data=test mean; var MasVnrArea;  run;
proc means data=test mean; var LotFrontage; run; 

data test_imp; set test;
IMP_MasVnrArea = MasVnrArea  ; m_MasVnrArea=0;
IMP_LotFrontage = LotFrontage; m_LotFrontage=0;
if missing(Imp_MasVnrArea) then do; IMP_MasVnrArea=105; m_MasVnrArea = 1;  end;
if missing(LotFrontage)    then do; IMP_LotFrontage=63; m_LotFrontage = 1; end;
run;

*replace vars with missings with imputed vars;
data test_imp; set test_imp; 
drop MasVnrArea LotFrontage Selected;
rename IMP_MasVnrArea = MasVnrArea;
rename IMP_LotFrontage = LotFrontage; run;

*reorder test data so saleprice is at the end;
data test_imp; 
retain MSSubClass20	MSSubClass30	MSSubClass40	MSSubClass45	MSSubClass50	MSSubClass60	MSSubClass70	MSSubClass75	MSSubClass80	MSSubClass85	MSSubClass90	MSSubClass120	MSSubClass160	MSSubClass180	MSSubClass190	MSZoningC	MSZoningFV	MSZoningRH	MSZoningRL	MSZoningRM	LotShapeIR1	LotShapeIR2	LotShapeIR3	LotShapeReg	LandContourBnk	LandContourHLS	LandContourLow	LandContourLvl	UtilitiesAllPub	UtilitiesNoSeWa	LotConfigCorner	LotConfigCulDSac	LotConfigFR2	LotConfigFR3	LotConfigInside	LandSlopeGtl	LandSlopeMod	LandSlopeSev	NeighborhoodBlmngtn	NeighborhoodBlueste	NeighborhoodBrDale	NeighborhoodBrkSide	NeighborhoodClearCr	NeighborhoodCollgCr	NeighborhoodCrawfor	NeighborhoodEdwards	NeighborhoodGilbert	NeighborhoodIDOTRR	NeighborhoodMeadowV	NeighborhoodMitchel	NeighborhoodNAmes	NeighborhoodNPkVill	NeighborhoodNWAmes	NeighborhoodNoRidge	NeighborhoodNridgHt	NeighborhoodOldTown	NeighborhoodSWISU	NeighborhoodSawyer	NeighborhoodSawyerW	NeighborhoodSomerst	NeighborhoodStoneBr	NeighborhoodTimber	NeighborhoodVeenker	Condition1Artery	Condition1Feedr	Condition1Norm	Condition1PosA	Condition1PosN	Condition1RRAe	Condition1RRAn	Condition1RRNe	Condition1RRNn	Condition2Artery	Condition2Feedr	Condition2Norm	Condition2PosA	Condition2PosN	Condition2RRAe	Condition2RRAn	Condition2RRNn	BldgType1Fam	BldgType2fmCon	BldgTypeDuplex	BldgTypeTwnhs	BldgTypeTwnhsE	HouseStyle1_5Fin	HouseStyle1_5Unf	HouseStyle1Story	HouseStyle2_5Fin	HouseStyle2_5Unf	HouseStyle2Story	HouseStyleSFoyer	HouseStyleSLvl	RoofStyleFlat	RoofStyleGable	RoofStyleGambr	RoofStyleHip	RoofStyleMansa	RoofStyleShed	RoofMatlClyTile	RoofMatlCompShg	RoofMatlMembran	RoofMatlMetal	RoofMatlRoll	RoofMatlTar_Grv	RoofMatlWdShake	RoofMatlWdShngl	HeatingFloo	HeatingGasA	HeatingGasW	HeatingGrav	HeatingOthW	HeatingWall	Exterior1stAsbShng	Exterior1stAsphShn	Exterior1stBrkComm	Exterior1stBrkFace	Exterior1stCBlock	Exterior1stCemntBd	Exterior1stHdBoard	Exterior1stImStucc	Exterior1stMetalSd	Exterior1stPlywood	Exterior1stStone	Exterior1stStucco	Exterior1stVinylSd	Exterior1stWd_Sdng	Exterior1stWdShing	Exterior2ndAsbShng	Exterior2ndAsphShn	Exterior2ndBrk_Cmn	Exterior2ndBrkFace	Exterior2ndCBlock	Exterior2ndCmentBd	Exterior2ndHdBoard	Exterior2ndImStucc	Exterior2ndMetalSd	Exterior2ndOther	Exterior2ndPlywood	Exterior2ndStone	Exterior2ndStucco	Exterior2ndVinylSd	Exterior2ndWd_Sdng	Exterior2ndWd_Shng	MasVnrTypeBrkCmn	MasVnrTypeBrkFace	MasVnrTypeNA	MasVnrTypeNone	MasVnrTypeStone	FoundationBrkTil	FoundationCBlock	FoundationPConc	FoundationSlab	FoundationStone	FoundationWood	ElectricalFuseA	ElectricalFuseF	ElectricalFuseP	ElectricalMix	ElectricalNA	ElectricalSBrkr	FunctionalMaj1	FunctionalMaj2	FunctionalMin1	FunctionalMin2	FunctionalMod	FunctionalSev	FunctionalTyp	GarageType2Types	GarageTypeAttchd	GarageTypeBasment	GarageTypeBuiltIn	GarageTypeCarPort	GarageTypeDetchd	GarageTypeNA	GarageFinishFin	GarageFinishNA	GarageFinishRFn	GarageFinishUnf	PavedDriveN	PavedDriveP	PavedDriveY	SaleTypeCOD	SaleTypeCWD	SaleTypeCon	SaleTypeNew	SaleTypeOth	SaleTypeWD	SaleConditionAbnorml	SaleConditionAdjLand	SaleConditionAlloca	SaleConditionFamily	SaleConditionNormal	SaleConditionPartial	BsmtFinType2ALQ	BsmtFinType2BLQ	BsmtFinType2GLQ	BsmtFinType2LwQ	BsmtFinType2NA	BsmtFinType2Rec	BsmtFinType2Unf	BsmtFinType1ALQ	BsmtFinType1BLQ	BsmtFinType1GLQ	BsmtFinType1LwQ	BsmtFinType1NA	BsmtFinType1Rec	BsmtFinType1Unf	StreetGrvl	StreetPave	CentralAirN	CentralAirY	BsmtFullBath	BsmtHalfBath	FullBath	HalfBath	BedroomAbvGr	KitchenAbvGr	TotRmsAbvGrd	Fireplaces	GarageCars	LotArea	BsmtFinSF1	TotalBsmtSF	_1stFlrSF	_2ndFlrSF	LowQualFinSF	GrLivArea	GarageArea	WoodDeckSF	OpenPorchSF	EnclosedPorch	_3SsnPorch	ScreenPorch	PoolArea	MiscVal	OverallQual	OverallCond	BsmtCond	BsmtExposure	BsmtQual	ExterCond	ExterQual	GarageCond	GarageQual	HeatingQC	KitchenQual	MasVnrArea	m_MasVnrArea YearBuilt YearRemodAdd GarageYrBlt MoSold YrSold LotFrontage m_LotFrontage	SalePrice
;set test_imp; run;


proc contents varnum data = train_imp; run; *varnum places variables according to their order;
proc contents varnum data = test_imp; run;



*mae and rmse macro that is to be used for pred vs actual tables;
%macro 
		mae_rmse(dataset /* Data set which contains the actual and predicted values */, 
		actual /* Variable which contains the actual or observed valued */, 
		predicted /* Variable which contains the predicted value */);
	%global mae rmse;

	/* Make the scope of the macro variables global */
	data &dataset;
		retain square_error_sum abs_error_sum;
		set &dataset 
        end=last /* Flag for the last observation */;
		error=&actual - &predicted;

		/* Calculate simple error */
		square_error=error * error;

		/* error^2 */
		if _n_ eq 1 then
			do;

				/* Initialize the sums */
				square_error_sum=square_error;
				abs_error_sum=abs(error);
			end;
		else
			do;

				/* Add to the sum */
				square_error_sum=square_error_sum + square_error;
				abs_error_sum=abs_error_sum + abs(error);
			end;

		if last then
			do;

				/* Calculate RMSE and MAE and store in SAS data set. */
				mae=abs_error_sum/_n_;
				rmse=sqrt(square_error_sum/_n_);

				/* Write to SAS log */
				put 'NOTE: ' mae=rmse=;

				/* Store in SAS macro variables */
				call symput('mae', put(mae, 20.10));
				call symput('rmse', put(rmse, 20.10));
			end;
	run;
%mend;


*Run Linear Regression - lr_scores contains table of lr predictions with col y_score ;
proc reg data=train_imp outest=lr_model;
   model SalePrice= MSSubClass20--m_LotFrontage; 
   output out=lr_train_scores predicted=y_score residual=resid ucl=ucl lcl=lcl cookd=cook;
   title 'Regression'; 
run;
%mae_rmse(lr_train_scores, SalePrice, y_score); *it is interesting that this train rmse doesn't match the output;

proc score data=test_imp score=lr_model out=lr_test_scores type=parms; *scores --> predictions;
   var MSSubClass20 -- m_LotFrontage;
   title 'Test Scores';
run;
%mae_rmse(lr_test_scores, SalePrice, MODEL1); *<-- test rmse, MODEL1 is the name of the y predictions;



*Stepwise Regression;
ods graphics on;
Proc Reg data=train_imp outest=stepwise_model;
	Title 'Stepwise Regression';
	model SalePrice= MSSubClass20--m_LotFrontage / 
		  selection=stepwise slentry=0.01 slstay=0.01 AIC VIF BIC MSE stb details=summary;
	output out=stepwise_train_scores pred=y_score residual=resid ucl=ucl lcl=lcl cookd=cook 
	covratio=cov dffits=dfits press=prss;
	run;
proc print data=stepwise_model; run;
%mae_rmse(stepwise_train_scores, SalePrice, y_score); *<-- test rmse, MODEL1 is the name of the y predictions;

proc score data=test_imp score=stepwise_model out=stepwise_test_scores type=parms; *scores --> predictions;
   var MSSubClass20 -- m_LotFrontage;
   title 'Test Scores';
run;
%mae_rmse(stepwise_test_scores, SalePrice, MODEL1); *<-- test rmse, MODEL1 is the name of the y predictions;
%put NOTE: mae=&mae rmse=&rmse; 


*Adjusted R-Squared Regression (TAKES WAY TOO LONG!);
ods graphics on;
Proc Reg data=train_imp outest=adjrsq_model;
	Title 'Adjusted R-Squared Regression';
	model SalePrice= MSSubClass20--m_LotFrontage / 
		  selection=ADJRSQ slentry=0.01 slstay=0.01 AIC VIF BIC MSE stb details=summary;
	output out=adjrsq_train_scores pred=y_score residual=resid ucl=ucl lcl=lcl cookd=cook 
	covratio=cov dffits=dfits press=prss;
	run;
proc print data=adjrsq_model; run;
%mae_rmse(adjrsq_train_scores, SalePrice, y_score); *<-- test rmse, MODEL1 is the name of the y predictions;

proc score data=test_imp score=adjrsq_model out=adjrsq_test_scores type=parms; *scores --> predictions;
   var MSSubClass20 -- m_LotFrontage;
   title 'Test Scores';
run;
%mae_rmse(adjrsq_test_scores, SalePrice, MODEL1); *<-- test rmse, MODEL1 is the name of the y predictions;
%put NOTE: mae=&mae rmse=&rmse; 




*Random Forests ;
*proc hpforest <--- i do not have this;





