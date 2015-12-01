/*Built in Dec 1, 2015*/
/*Autho Namdev Patap*/
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<direct.h>
#include<math.h>
#define NUMOP 59
#define NUMAD 6
#define NUMREG 9
#define MAXSYM 50
/*Global*/
struct optable{/*OP code Table*/
	char name[8];
	unsigned int opcode;
	unsigned int format;
}arOpTable[NUMOP]={"ADD",0x18,3,"ADDF",0x58,3,"ADDR",0x90,2,"AND",0x40,3,
"CLEAR",0xB4,2,"COMP",0x28,3,"COMPF",0x88,3,"COMPR",0xA0,2,
"DIV",0x24,3,"DIVF",0x64,3,"DIVR",0x9C,2,"FIX", 0xC4,1,
"FLOAT",0xC0,1,"HIO",0xF4,1,"J",0x3C,3,"JEQ",0x30,3,
"JGT",0x34,3,"JLT",0x38,3,"JSUB",0x48,3,"LDA",0x00,3,
"LDB",0x68,3,"LDCH",0x50,3,"LDF",0x70,3,"LDL",0x08,3,
"LDS",0x6C,3,"LDT",0x74,3,"LDX",0x04,3,"LPS",0xD0,3,
"MUL",0x20,3,"MULF",0x60,3,"MULR",0x98,2,"NORM",0xC8,1,
"OR",0x44,3,"RD",0xD8,3,"RMO",0xAC,2,"RSUB",0x4C,3,
"SHIFTL",0xA4,2,"SHIFTR",0xA8,2,"SIO",0xF0,1,"SSK",0xEC,3,
"STA",0x0C,3,"STB",0x78,3,"STCH",0x54,3,"STF",0x80,3,
"STI",0xD4,3,"STL",0x14,3,"STS",0x7C,3,"STSW",0xE8,3,
"STT",0x84,3,"STX",0x10,3,"SUB",0x1C,3,"SUBF",0x5C,3,
"SUBR",0x94,2,"SVC",0xB0,2,"TD",0xE0,3,"TIO",0xF8,1,
"TIX",0x2C,3,"TIXR",0xB8,2,"WD",0xDC,3};
struct addtable{/*Address Table*/
	char name[8];
}arAddTable[NUMAD]={"START","END","BYTE","WORD","RESB","RESW"};
struct symtable{/*Symbol Table*/
	char name[8];
	unsigned int locctr;
}arSymTable[MAXSYM];
unsigned int hextoint(char *S){/*Covert HEX strings to integer*/
	char Hex[17]="0123456789ABCDEF";
	unsigned int retInteger=0,nTemp,i,j;
	strupr(S);
	for(i=0;i<strlen(S);i++){
		for(j=0,nTemp=1;j<strlen(Hex);j++){
			if(*(S+i)==*(Hex+j)){
				nTemp*=j;
				break;
			}
		}
		retInteger+=(nTemp*=(int)pow(16,strlen(S)-i-1));
	}
	return retInteger;
}
unsigned int find_comment(char *S){/*Comment*/
	if(S[0]!='.'){
		return -1;
	}else{
		return 1;
	}
}
int find_optable(char *S){/*find Op Table*/
	int i,nRet=-1;
	for(i=0;i<NUMOP;i++){
		if(stricmp(arOpTable[i].name,S)==0){
			nRet=i;
			break;
		}
	}
	return nRet;
}
int find_addtable(char *S){/*find Address Table*/
	int i,nRet=-1;
	for(i=0;i<NUMAD;i++){
		if(stricmp(arAddTable[i].name,S)==0){
			nRet=i;
			break;
		}
	}
	return nRet;
}
unsigned int length_Byte(char *S){/*Count BYTE length*/
	unsigned int nRet=0;
	char chSep[]="\'",Temp[64];
	strtok(S,chSep);
	strcpy(Temp,strtok(NULL,chSep));
	if(S[0]=='C'||S[0]=='c'){
		nRet=(unsigned int)strlen(Temp);
	}else if(S[0]=='X'||S[0]=='x'){
		nRet=(unsigned int)(strlen(Temp)/2);
	}
	return nRet;
}
unsigned int setup_symtable(char *S,unsigned int MAX){/*find Address Table*/
	unsigned int i,nRet=0;
	for(i=0;i<MAX;i++){
		if(stricmp(arSymTable[i].name,S)==0){
			nRet++;
		}
	}
	return ((nRet>0)?(nRet-1):nRet);
}
unsigned int funPassFirst(FILE *SOURCE,FILE *INTERMEDIATE,FILE *SYMTABLE){/*Pass First*/
	unsigned int nSymCounter=0;/*symbol table counter*/
	unsigned int Starting_Address=0;/*start address*/
	unsigned int PC=0;/*program counter*/
	unsigned int hextoint(char *S);
	unsigned int i,nOpRet=0,LOCCTR=0,length_Source=0;
	/*Fixed in May 7, 2009*/
	/*funRet change to INT from UNSIGNED INT*/
	int funRet=0;
	char chLine[128],Temp[128]={' '};
	char LABEL[32],OPCODE[32],OPERAND[32],Temp32[32]={' '};
	char *strToken,chSep[]="	\n";
	/*read first input line*/
	fgets(chLine,128,SOURCE);
	strcpy(Temp,chLine);
	strcpy(LABEL,strtok(Temp,chSep));
	strcpy(OPCODE,strtok(NULL,chSep));
	strcpy(OPERAND,strtok(NULL,chSep));
	if(stricmp(OPCODE,"START")==0){/*OPCODE='START'*/
		/*save #[OPERAND] as starting address*/
		Starting_Address=hextoint(OPERAND);
		/*initialize LOCCTR to starting address*/
		PC=Starting_Address;
		/*write line to intermediate file*/
		strcpy(Temp,strupr(itoa(PC,Temp32,16)));
		strcat(Temp,"	");
		strcat(Temp,chLine);
		fputs(Temp,INTERMEDIATE);
		/*read next input line*/
		fgets(chLine,128,SOURCE);
		strcpy(Temp,chLine);
		strcpy(LABEL,strtok(Temp,chSep));
		strcpy(OPCODE,strtok(NULL,chSep));
		strcpy(OPERAND,strtok(NULL,chSep));
	}else{
		PC=0;
	}/*if START*/
	while(stricmp(OPCODE,"END")!=0){
		if(find_comment(chLine)!=1){
			if(LABEL[0]!='	'){
				/*search SYMTAB for other LABEL*/
				strcpy(arSymTable[nSymCounter].name,LABEL);
				if(setup_symtable(LABEL,nSymCounter)!=0){/*found*/
					/*set error flag (duplicate symbol)*/
					funRet=-1;
					printf("Error: duplicate symbol.\n");
					break;
				}else{
					/*insert (LABEL,LOCCTR) into SYMTAB*/
					arSymTable[nSymCounter].locctr=PC;
					nSymCounter++;
				}
			}/*if symbol*/
			nOpRet=find_optable(OPCODE);
			if(nOpRet!=-1){/*found OPCODE*/
				LOCCTR=PC;
				PC+=3;
			}else if(find_addtable(OPCODE)==3){/*WORD*/
				LOCCTR=PC;
				PC+=3;
			}else if(find_addtable(OPCODE)==5){/*RESW*/
				LOCCTR=PC;
				PC+=3*atoi(OPERAND);
			}else if(find_addtable(OPCODE)==4){/*RESB*/
				LOCCTR=PC;
				PC+=atoi(OPERAND);
			}else if(find_addtable(OPCODE)==2){/*BYTE*/
				LOCCTR=PC;
				PC+=length_Byte(OPERAND);
			}else{
				/*set error flag(invalid operation code)*/
				funRet=-1;
				printf("Error: invalid operation code.\n");
				break;
			}
		}/*if not a comment*/
		/*write line to intermediate file*/
		if(find_comment(chLine)!=1){
			strcpy(Temp,strupr(itoa(LOCCTR,Temp32,16)));
			strcat(Temp,"	");
			chLine[strlen(chLine)-1]='\0';
			strcat(Temp,chLine);
			strcat(Temp,"\n");
		}else{
			strcpy(Temp,chLine);
		}
		fputs(Temp,INTERMEDIATE);
		/*read next input line*/
		fgets(chLine,128,SOURCE);
		if(find_comment(chLine)!=1){
			strcpy(Temp,chLine);
			if(Temp[0]=='	'){
				strcpy(LABEL,"	");
				strcpy(OPCODE,strtok(Temp,chSep));
				strToken=strtok(NULL,chSep);
				if(strToken==NULL){
					strcpy(OPERAND,"	");
				}else{
					strcpy(OPERAND,strToken);
				}
			}else{
				strcpy(LABEL,strtok(Temp,chSep));
				strcpy(OPCODE,strtok(NULL,chSep));
				strcpy(OPERAND,strtok(NULL,chSep));
			}
		}
	}/*while not END*/
	if(funRet==-1){
		return funRet;
	}
	/*write last line to intermediate file*/
	if(chLine[strlen(chLine)-1]!='\n'){
		strcat(chLine,"\n");
	}
	strcpy(Temp,chLine);
	fputs(Temp,INTERMEDIATE);
	/*save (LOCCTR-starting address) as program length*/
	length_Source=PC-Starting_Address;
	if(funRet!=-1){
		funRet=length_Source;
	}
	strcpy(Temp,"\n! Length_of_the_SIC_Source= ");
	strcat(Temp,strupr(itoa(length_Source,Temp32,16)));
	strcat(Temp,"\n");
	fputs(Temp,INTERMEDIATE);
	for(i=0;i<nSymCounter;i++){
		strcpy(Temp,arSymTable[i].name);
		strcat(Temp,"	");
		strcat(Temp,strupr(itoa(arSymTable[i].locctr,Temp32,16)));
		strcat(Temp,"\n");
		fputs(Temp,SYMTABLE);
	}
	return funRet;
}/*Pass First*/
/*main function*/
int main(int argc,char *argv[]){
	FILE *fSource,*fIntermediate,*fSymTable;
	unsigned int sic_length=0;
	char name[1][128];
	char pathIntermediate[256],pathSymbolTable[256];
	char cwdBuffer[_MAX_PATH];
	/*Fixed in May 1, 2009*/
	printf("(Dec 10, 2005) sic1.c Released!!\n");
	printf("(May 10, 2007) sic1.c Fixed!!\n");
	printf("(May 1, 2009) sic2.c Fixed!!\n");
	printf("Author's Website: http://tw.myblog.yahoo.com/mjshya/\n");
	printf("Author's Website: http://johnmhsheep.pixnet.net/\n\n");
	if(argc!=2){
		printf("Input SIC source file name\n(e.g. 123.txt): ");
		scanf("%s",&name[0]);
		argv[1]=name[0];
	}
	fSource=fopen(argv[1],"r");
	if(fSource==NULL){
		printf("Open Source File Failure!!\n");
		printf("Check Files Please!!\n");
		system("pause");
		exit(0);
	}
	getcwd(cwdBuffer,_MAX_PATH);
	strcpy(pathIntermediate,cwdBuffer);
	strcat(pathIntermediate,"\\intermed\\interMed.txt");
	strcpy(pathSymbolTable,cwdBuffer);
	strcat(pathSymbolTable,"\\intermed\\symTable.txt");
	mkdir("intermed");
	fIntermediate=fopen(pathIntermediate,"w");
	fSymTable=fopen(pathSymbolTable,"w");
	if(fSource!=NULL||fIntermediate!=NULL||fSymTable!=NULL){
		if((sic_length=funPassFirst(fSource,fIntermediate,fSymTable))!=-1){
			fclose(fSource);
			fclose(fSymTable);
			fclose(fIntermediate);
			printf("...Address Completed!!\n");
			system("pause");
		}else{
			fclose(fSource);
			fclose(fIntermediate);
			fclose(fSymTable);
			system("pause");
			exit(0);
		}
	}else{
		printf("Open Source, Destination and Symbol_Table Files Failure!!\n");
		printf("Check Files Please!!\n");
		system("pause");
	}
	return 0;
}/*main function*/
