{*******************************************************}
{                                                       }
{               HCView V1.0  ���ߣ���ͨ                 }
{                                                       }
{      ��������ѭBSDЭ�飬����Լ���QQȺ 649023932      }
{            ����ȡ����ļ������� 2018-5-4              }
{                                                       }
{                  HCView���빫����Ԫ                   }
{                                                       }
{*******************************************************}

unit HCCommon;

interface

uses
  Windows, Controls, Classes, Graphics, HCStyle;

const
  CFE_EXCEPTION = 'CFE�쳣��';
  HC_EXT = '.hcf';

  HC_FileVersion = '1.0';
  HC_FileVersionInt = 10;

  MinPadding = 20;
  PMSLineHeight = 24;  // ��д��Χ�ߵĳ���
  AnnotationWidth = 200;  // ��ע��ʾ�������
  // ���������׵��ַ�             |                    |                   |
  DontLineFirstChar = '`-=[]\;'',./~!@#$%^&*()_+{}|:"<>?�����������ܣ���������������������������������������������������������';
  DontLineLastChar = '/\��';

  /// <summary> �����RectItemǰ�� </summary>
  OffsetBefor = 0;

  /// <summary> �����RectItem������ </summary>
  OffsetInner = 1;

  /// <summary> �����RectItem���� </summary>
  OffsetAfter = 2;

type
  TChangeProc = reference to function(): Boolean;

  TViewModel = (
    vmPage,  // ҳ����ͼ����ʾҳü��ҳ��
    vmWeb  // Web��ͼ������ʾҳü��ҳ��
  );

  TSectionArea = (saHeader, saData, saFooter);  // ��ǰ��������ĵ���һ����
  TSaveParts = set of TSectionArea;  // ����ʱ���ļ���������

  TPaperSize = (psCustom, ps4A0, ps2A0, psA0, psA1, psA2,
    psA3, psA4, psA5, psA6, psA7, psA8,
    psA9, psA10, psB0, psB1, psB2, psB3,
    psB4, psB5, psB6, psB7, psB8, psB9,
    psB10, psC0, psC1, psC2, psC3, psC4,
    psC5, psC6, psC7, psC8, psC9, psC10,
    psLetter, psLegal, psLedger, psTabloid,
    psStatement, psQuarto, psFoolscap, psFolio,
    psExecutive, psMonarch, psGovernmentLetter,
    psPost, psCrown, psLargePost, psDemy,
    psMedium, psRoyal, psElephant, psDoubleDemy,
    psQuadDemy, psIndexCard3_5, psIndexCard4_6,
    psIndexCard5_8, psInternationalBusinessCard,
    psUSBusinessCard, psEmperor, psAntiquarian,
    psGrandEagle, psDoubleElephant, psAtlas,
    psColombier, psImperial, psDoubleLargePost,
    psPrincess, psCartridge, psSheet, psHalfPost,
    psDoublePost, psSuperRoyal, psCopyDraught,
    psPinchedPost, psSmallFoolscap, psBrief, psPott,
    psPA0, psPA1, psPA2, psPA3, psPA4, psPA5,
    psPA6, psPA7, psPA8, psPA9, psPA10, psF4,
    psA0a, psJISB0, psJISB1, psJISB2, psJISB3,
    psJISB4, psJISB5, psJISB6, psJISB7, psJISB8,
    psJISB9, psJISB10, psJISB11, psJISB12,
    psANSI_A, psANSI_B, psANSI_C, psANSI_D,
    psANSI_E, psArch_A, psArch_B, psArch_C,
    psArch_D, psArch_E, psArch_E1,
    ps16K, ps32K);

  TCaretInfo = record
    X, Y, Height: Integer;
    Visible: Boolean;
  end;

  TMarkType = (cmtBeg, cmtEnd);

  TCaret = Class
  private
    FHeight: Integer;
    FOwnHandle: THandle;
  protected
    procedure SetHeight(const Value: Integer);
  public
    X, Y: Integer;
    //Visible: Boolean;
    constructor Create(const AHandle: THandle);
    destructor Destroy; override;
    procedure ReCreate;
    procedure Show(const AX, AY: Integer); overload;
    procedure Show; overload;
    procedure Hide;
    property Height: Integer read FHeight write SetHeight;
  end;

  TZoomInfo = record
    MapMode: Integer;
    WindowOrg: TSize;
    WindowExt: TSize;
    ViewportOrg: TSize;
    ViewportExt: TSize;
  end;

  function IsKeyPressWant(const AKey: Char): Boolean;
  function IsKeyDownWant(const AKey: Word): Boolean;

  function PosCharHC(const AChar: Char; const AStr: string{; const Offset: Integer = 1}): Integer;

  /// <summary>
  /// ����ָ��λ�����ַ����ĸ��ַ�����(0����һ��ǰ��)
  /// </summary>
  /// <param name="ACanvas"></param>
  /// <param name="AText"></param>
  /// <param name="X"></param>
  /// <returns></returns>
  function GetCharOffsetByX(const ACanvas: TCanvas; const AText: string; const X: Integer): Integer;

  // ���ݺ��ִ�С��ȡ�������ִ�С
  function GetFontSize(const AFontSize: string): Integer;

  function GetVersionAsInteger(const AVersion: string): Integer;

  /// <summary> �����ļ���ʽ���汾 </summary>
  procedure _SaveFileFormatAndVersion(const AStream: TStream);
  /// <summary> ��ȡ�ļ���ʽ���汾 </summary>
  procedure _LoadFileFormatAndVersion(const AStream: TStream; var AFileFormat, AVersion: string);

  {$IFDEF DEBUG}
  procedure DrawDebugInfo(const ACanvas: TCanvas; const ALeft, ATop: Integer; const AInfo: string);
  {$ENDIF}

var
  GCursor: TCursor;
  HC_FILEFORMAT: Word;

implementation

uses
  SysUtils;

{$IFDEF DEBUG}
procedure DrawDebugInfo(const ACanvas: TCanvas; const ALeft, ATop: Integer; const AInfo: string);
var
  vFont: TFont;
begin
  vFont := TFont.Create;
  try
    vFont.Assign(ACanvas.Font);
    ACanvas.Font.Color := clGray;
    ACanvas.Font.Size := 8;
    ACanvas.Font.Style := [];
    ACanvas.Font.Name := 'Courier New';
    ACanvas.Brush.Style := bsClear;

    ACanvas.TextOut(ALeft, ATop, AInfo);
  finally
    ACanvas.Font.Assign(vFont);
    FreeAndNil(vFont);
  end;
end;
{$ENDIF}

function IsKeyPressWant(const AKey: Char): Boolean;
begin
  Result := AKey in [#32..#126];  // <#32��ASCII������ #127��ASCII DEL
end;

function IsKeyDownWant(const AKey: Word): Boolean;
begin
  Result := AKey in [VK_BACK, VK_DELETE, VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_RETURN,
    VK_HOME, VK_END, VK_TAB];
end;

function PosCharHC(const AChar: Char; const AStr: string{; const Offset: Integer = 1}): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Length(AStr) do
  begin
    if AChar = AStr[i] then
    begin
      Result := i;
      Exit
    end;
  end;
end;

function GetFontSize(const AFontSize: string): Integer;
begin
  Result := 10;
  if not TryStrToInt(AFontSize, Result) then
  begin
    if AFontSize = '����' then Result := 42
    else
    if AFontSize = 'С��' then Result := 36
    else
    if AFontSize = 'һ��' then Result := 26
    else
    if AFontSize = 'Сһ' then Result := 24
    else
    if AFontSize = '����' then Result := 22
    else
    if AFontSize = 'С��' then Result := 18
    else
    if AFontSize = '����' then Result := 16
    else
    if AFontSize = 'С��' then Result := 15
    else
    if AFontSize = '�ĺ�' then Result := 14
    else
    if AFontSize = 'С��' then Result := 12
    else
    if AFontSize = '���' then Result := Round(10.5)//Trunc(10.5)
    else
    if AFontSize = 'С��' then Result := 9
    else
    if AFontSize = '����' then Result := Round(7.5)
    else
    if AFontSize = 'С��' then Result := Round(6.5)
    else
    if AFontSize = '�ߺ�' then Result := Round(5.5);
  end;
end;

function GetVersionAsInteger(const AVersion: string): Integer;
var
  vsVer: string;
  i: Integer;
begin
  Result := 0;
  for i := 1 to Length(AVersion) do
  begin
    if AVersion[i] in ['0'..'9'] then
      vsVer := vsVer + AVersion[i];
  end;
  Result := vsVer.ToInteger;
end;

/// <summary> �����ļ���ʽ���汾 </summary>
procedure _SaveFileFormatAndVersion(const AStream: TStream);
var
  vS: string;
begin
  vS := HC_EXT;
  AStream.WriteBuffer(vS[1], Length(vS) * SizeOf(Char));
  // �汾
  vS := HC_FileVersion;
  AStream.WriteBuffer(vS[1], Length(vS) * SizeOf(Char));
end;

/// <summary> ��ȡ�ļ���ʽ���汾 </summary>
procedure _LoadFileFormatAndVersion(const AStream: TStream; var AFileFormat, AVersion: string);
begin
  // �ļ���ʽ
  SetLength(AFileFormat, Length(HC_EXT));
  AStream.ReadBuffer(AFileFormat[1], Length(HC_EXT) * SizeOf(Char));

  // �汾
  SetLength(AVersion, Length(HC_FileVersion));
  AStream.ReadBuffer(AVersion[1], Length(HC_FileVersion) * SizeOf(Char));
end;

function GetCharOffsetByX(const ACanvas: TCanvas; const AText: string; const X: Integer): Integer;
var
  i, vX, vCharWidth: Integer;
begin
  Result := -1;
  vX := 0;
  for i := 1 to Length(AText) do  { TODO : �пո�Ϊ���ַ�����Ч }
  begin
    vCharWidth := ACanvas.TextWidth(AText[i]);
    vX := vX + vCharWidth;
    if vX > X then  // ��ǰ�ַ�����λ����X��
    begin
      if vX - vCharWidth div 2 > X then  // �����ǰ�벿��
        Result := i - 1  // ��Ϊǰһ������
      else
        Result := i;
      Break;
    end;
  end;
end;

{ TCaret }

constructor TCaret.Create(const AHandle: THandle);
begin
  FOwnHandle := AHandle;
  CreateCaret(FOwnHandle, 0, 2, 20);
end;

destructor TCaret.Destroy;
begin
  DestroyCaret;
  FOwnHandle := 0;
  inherited;
end;

procedure TCaret.Hide;
begin
  HideCaret(FOwnHandle);
end;

procedure TCaret.ReCreate;
begin
  DestroyCaret;
  CreateCaret(FOwnHandle, 0, 2, FHeight);
end;

procedure TCaret.SetHeight(const Value: Integer);
begin
  if FHeight <> Value then
  begin
    FHeight := Value;
    ReCreate;
  end;
end;

procedure TCaret.Show;
begin
  Show(X, Y);
end;


procedure TCaret.Show(const AX, AY: Integer);
begin
  ReCreate;
  SetCaretPos(AX, AY);
  ShowCaret(FOwnHandle);
end;

initialization
  if HC_FILEFORMAT = 0 then
    HC_FILEFORMAT := RegisterClipboardFormat(HC_EXT);

end.