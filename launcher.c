/* Windows x64 GUI launcher: opens local Troubleshooter.html in Edge app window.
   No network calls or privileged operations. Build with LLVM clang/lld-link. */
typedef unsigned long DWORD;
typedef unsigned short WCHAR;
typedef void* HANDLE;
__declspec(dllimport) DWORD __stdcall GetModuleFileNameW(HANDLE, WCHAR*, DWORD);
__declspec(dllimport) DWORD __stdcall GetFileAttributesW(const WCHAR*);
__declspec(dllimport) HANDLE __stdcall ShellExecuteW(HANDLE,const WCHAR*,const WCHAR*,const WCHAR*,const WCHAR*,int);
__declspec(dllimport) int __stdcall MessageBoxW(HANDLE,const WCHAR*,const WCHAR*,unsigned int);
#define W(x) L##x
static WCHAR path[32768],url[32768],args[32768];
static const WCHAR openVerb[]=L"open", edge[]=L"msedge.exe", title[]=L"Terminal Troubleshooter";
static const WCHAR errorMsg[]=L"Troubleshooter.html was not found next to this EXE. Extract the entire ZIP and try again.";
static const WCHAR fallbackMsg[]=L"Microsoft Edge app mode could not start. The interface will open in your default browser.";
static void cat(WCHAR* a,const WCHAR* b){int i=0,j=0;while(a[i])i++;while(b[j])a[i++]=b[j++];a[i]=0;}
void WinMainCRTStartup(void){
 DWORD n=GetModuleFileNameW((HANDLE)0,path,32700);
 if(n==0||n>=32700)return;
 int i=(int)n-1;while(i>=0&&path[i]!=L'\\'&&path[i]!=L'/')i--;
 path[i+1]=0;
 cat(path,L"Troubleshooter.html");
 if(GetFileAttributesW(path)==0xffffffffUL){MessageBoxW(0,errorMsg,title,0x10);return;}
 // Chrome/Edge app mode takes a local file URL; no internet connection is needed.
 cat(url,L"file:///");
 for(i=0;path[i];i++){WCHAR c=path[i];if(c==L'\\')c=L'/';int k=0;while(url[k])k++;url[k]=c;url[k+1]=0;}
 cat(args,L"--app=\"");cat(args,url);cat(args,L"\" --window-size=1360,900");
 HANDLE result=ShellExecuteW(0,openVerb,edge,args,0,1);
 if((unsigned long long)result<=32){
   MessageBoxW(0,fallbackMsg,title,0x40);
   ShellExecuteW(0,openVerb,path,0,0,1);
 }
}
