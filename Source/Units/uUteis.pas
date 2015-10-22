unit uUteis;

interface
  uses System.IniFiles, System.SysUtils, Vcl.Forms, Winapi.Windows, iwSystem, ULanguage;

  //Marcones Freitas - 16/10/2015 -> Algumas Constantes Novas
 const
 cGeneral            = 'General';
 cHost               = 'Host';
 cPort               = 'Port';
 cGroup              = 'Group';
 cMachine            = 'Machine';
 cConnectTimeOut     = 'ConnectTimeOut';
 cStarterWithWindows = 'StarterWithWindows';
 cYes                = 'YES';
 cNO                 = 'NO';
 cLanguage           = 'Language';

 procedure SaveIni(Param, Value, ArqFile, Name: String; encrypted: Boolean);
 function GetIni(Path, Key, KeyValue : string; encrypted: Boolean): string;
 function EnDecryptString(StrValue : String; Key: Word) : String;
 function ActiveProcess(AValue: String = ''): Boolean;
 procedure ReadCaptions(language : Integer);
 procedure SetHostPortGroupMach;
 procedure SetLanguage;

var
 xLanguage : Integer;
 Languages : TLanguage;
 Host, vGroup, vMachine : string;
 Port, ConnectionTimeout : Integer;
 vParID, vParSenha: string;
implementation

uses Form_Main;

procedure SaveIni(Param, Value, ArqFile, Name: String; encrypted: Boolean);
var ArqIni : TIniFile;
    I: Integer;
begin
  ArqIni := TIniFile.Create(ArqFile);
  IF encrypted THEN
     Value := EnDecryptString(Value,250);

  ArqIni.WriteString(Name, Param, Value);
  ArqIni.Free;
end;

function GetIni(Path, Key, KeyValue : string; encrypted: Boolean): string;
var ArqIni : TIniFile;
    ValueINI : string;
begin
  ArqIni := TIniFile.Create(Path);

  ValueINI := ArqIni.ReadString(Key, KeyValue, ValueINI);
  if ValueINI = '' then
     ValueINI := '0'
  else
  IF encrypted THEN
     ValueINI := EnDecryptString(ValueINI,250);

  Result := ValueINI;
  ArqIni.Free;
end;


function EnDecryptString(StrValue : String; Key: Word) : String;
var I: Integer; OutValue : String;
begin
  OutValue := '';
  for I := 1 to Length(StrValue) do
      OutValue := OutValue + char(Not(ord(StrValue[I])-Key));

  Result := OutValue;
end;


function ActiveProcess(AValue: String = ''): Boolean;
begin
  if AnsiSameStr(AValue, EmptyStr) then
     AValue := ExtractFileName(Application.ExeName);

  CreateSemaphore(nil, 1, 1, PChar(AValue));
  Result := (GetLastError = ERROR_ALREADY_EXISTS);
end;

procedure ReadCaptions(language : Integer);
Var
  IniFile : string;
begin
  IniFile := gsAppPath + 'Language';
  Languages.Free;
  Languages := TLanguage.Create();

  if(language = 0)then
   begin
     Languages.YourID_Label       := String(GetIni(IniFile +'\US.ini','CAPTIONS','YourID_Label',false));
     Languages.YourPassword_Label := String(GetIni(IniFile +'\US.ini','CAPTIONS','YourPassword_Label',false));
     Languages.TargetID_Label     := String(GetIni(IniFile +'\US.ini','CAPTIONS','TargetID_Label',false));
     Languages.Language_Label     := String(GetIni(IniFile +'\US.ini','CAPTIONS','Language_Label',false));
   end
  else
  if(language = 1)then
     begin
      Languages.YourID_Label       := String(GetIni(IniFile +'\Pt_Br.ini','CAPTIONS','YourID_Label',false));
      Languages.YourPassword_Label := String(GetIni(IniFile +'\Pt_Br.ini','CAPTIONS','YourPassword_Label',false));
      Languages.TargetID_Label     := String(GetIni(IniFile +'\Pt_Br.ini','CAPTIONS','TargetID_Label',false));
      Languages.Language_Label     := String(GetIni(IniFile +'\Pt_Br.ini','CAPTIONS','Language_Label',false));
     end

end;

procedure SetHostPortGroupMach;
begin
  frm_Main.Main_Socket.Host     := Host;
  frm_Main.Main_Socket.Port     := Port;
  frm_Main.Desktop_Socket.Host  := Host;
  frm_Main.Desktop_Socket.Port  := Port;
  frm_Main.Keyboard_Socket.Host := Host;
  frm_Main.Keyboard_Socket.Port := Port;
  frm_Main.Files_Socket.Host    := Host;
  frm_Main.Files_Socket.Port    := Port;
end;

procedure SetLanguage;
begin
  xLanguage := strtoint(GetIni(ExtractFilePath(Application.ExeName) + Application.Title + '.ini', cGeneral, cLanguage, true));
  ReadCaptions(xLanguage);
  frm_Main.YourID_Label.Caption       := Languages.YourID_Label;
  frm_Main.YourPassword_Label.Caption := Languages.YourPassword_Label;
  frm_Main.TargetID_Label.Caption     := Languages.TargetID_Label;
end;


end.
