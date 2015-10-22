unit Form_Config;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Samples.Spin,
  Vcl.Buttons, Vcl.Imaging.pngimage, Vcl.ExtCtrls, registry, dxGDIPlusClasses;

type
  Tfrm_Config = class(TForm)
    lblHost: TLabel;
    lblGroup: TLabel;
    lblMachine: TLabel;
    lblTimeOut: TLabel;
    edtMachineName: TEdit;
    edtGroup: TEdit;
    edtHost: TEdit;
    sbSave: TSpeedButton;
    seTimeOut: TSpinEdit;
    chkStarter: TCheckBox;
    tmrCheck: TTimer;
    lblPort: TLabel;
    sePort: TSpinEdit;
    Language_Label: TLabel;
    cbxLanguage: TComboBox;
    TopBackground_Image: TImage;
    Label1: TLabel;
    PasswordIcon_Image: TImage;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure tmrCheckTimer(Sender: TObject);
    procedure sbSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frm_Config: Tfrm_Config;

implementation

{$R *.dfm}

uses Form_Main, uUteis;

procedure Tfrm_Config.FormCreate(Sender: TObject);
var Reg: TRegistry; S: string;
begin
 edtHost.Text          := GetIni(ExtractFilePath(Application.ExeName) + Application.Title+'.ini', cGeneral, cHost, True);
 sePort.Text           := GetIni(ExtractFilePath(Application.ExeName) + Application.Title+'.ini', cGeneral, cPort, True);
 edtGroup.Text         := GetIni(ExtractFilePath(Application.ExeName) + Application.Title+'.ini', cGeneral, cGroup, True);
 edtMachineName.Text   := GetIni(ExtractFilePath(Application.ExeName) + Application.Title+'.ini', cGeneral, cMachine, True);
 seTimeOut.Text        := GetIni(ExtractFilePath(Application.ExeName) + Application.Title+'.ini', cGeneral, cConnectTimeOut, True);
 s                     := GetIni(ExtractFilePath(Application.ExeName) + Application.Title+'.ini', cGeneral, cStarterWithWindows, True);
 cbxLanguage.ItemIndex := StrToInt(GetIni(ExtractFilePath(Application.ExeName) + Application.Title+'.ini', cGeneral, cLanguage, True));

 if s = cYes then
    chkStarter.Checked := True
 else
     chkStarter.Checked := False;
end;

procedure Tfrm_Config.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  //Marcones Freitas - 16/10/2015 -> Disable Alt + F4
  if (Key = VK_F4) or (Key = VK_ESCAPE) then
      Key := 0;
end;

procedure Tfrm_Config.FormKeyPress(Sender: TObject; var Key: Char);
begin
  //Marcones Freitas - 16/10/2015 -> Pula para o proximo campo com o ENTER
  IF Key = #13 THEN
    BEGIN
     Key := #0;
     Perform(Wm_NextDlgCtl,0,0);
    END;
end;

procedure Tfrm_Config.FormShow(Sender: TObject);
begin
 tmrCheck.Enabled := True;
end;

procedure Tfrm_Config.sbSaveClick(Sender: TObject);
var Reg: TRegistry; S: string;
begin
  Reg         := TRegistry.Create;
  S           :=ExtractFileDir(Application.ExeName)+'\'+ExtractFileName(Application.ExeName);
  Reg.rootkey :=HKEY_LOCAL_MACHINE;
  Reg.Openkey('SOFTWARE\MICROSOFT\WINDOWS\CURRENTVERSION\RUN',false);
  if chkStarter.Checked then
      begin
       Reg.WriteString(Caption, S);
       SaveIni(cStarterWithWindows, cYes, ExtractFilePath(Application.ExeName) + Application.Title+'.ini', cGeneral,True);
      end
  else
      begin
       Reg.DeleteValue(Caption);
       SaveIni(cStarterWithWindows, cNO, ExtractFilePath(Application.ExeName) + Application.Title+'.ini',cGeneral,True);
      end;

  SaveIni(cHost,           edtHost.Text,                   ExtractFilePath(Application.ExeName) + Application.Title+'.ini',cGeneral,True);
  SaveIni(cPort,           sePort.Text,                    ExtractFilePath(Application.ExeName) + Application.Title+'.ini',cGeneral,True);
  SaveIni(cMachine,        edtMachineName.Text,            ExtractFilePath(Application.ExeName) + Application.Title+'.ini',cGeneral,True);
  SaveIni(cGroup,          edtGroup.Text,                  ExtractFilePath(Application.ExeName) + Application.Title+'.ini',cGeneral,True);
  SaveIni(cConnectTimeOut, seTimeOut.Text,                 ExtractFilePath(Application.ExeName) + Application.Title+'.ini',cGeneral,True);
  SaveIni(cLanguage,       IntToStr(cbxLanguage.ItemIndex),ExtractFilePath(Application.ExeName) + Application.Title+'.ini',cGeneral,True);

  Host              := edtHost.Text;
  Port              := sePort.Value;
  vGroup            := edtGroup.Text;
  vMachine          := edtMachineName.Text;
  ConnectionTimeout := seTimeOut.Value;
  SetHostPortGroupMach;

  Close;
end;

procedure Tfrm_Config.tmrCheckTimer(Sender: TObject);
begin
  //Marcones Freitas - 16/10/2015 -> Somente Libera o Bot�o Salvar se os campos estiverem preenchidos
  if (edtHost.Text = '') or
      (edtGroup.Text = '') or
        (edtMachineName.Text = '') or
          (seTimeOut.Value = 0) or
             (sePort.Value = 0)then
      sbSave.Enabled := False
  else
      sbSave.Enabled := True;
end;

end.
