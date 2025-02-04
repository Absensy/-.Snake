unit Unit3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Menus, Vcl.Buttons, Vcl.Imaging.pngimage, Vcl.Mask, Vcl.CheckLst, ShellAPI;

type
  TDirection = (dirUp, dirDown, dirLeft, dirRight);
  TForm3 = class(TForm)
    DrawGrid1: TDrawGrid;
    Image1: TImage;
    BitBtn3: TBitBtn;
    Image2: TImage;
    Timer2: TTimer;
    Label1: TLabel;
    Image3: TImage;
    BitBtn1: TBitBtn;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N6: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DrawGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Timer2Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure CreateParams(var Params: TCreateParams) ; override;
    procedure N4Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
  private
    { Private declarations }
    SnakeSpeed: Integer;
    SnakeColor: Integer;
    SnakeBorder: Integer;
    Obstacles: array of TRect;
    Snake: array of TPoint;
    Food: TPoint;
    Score: Integer;
    Direction: TDirection;
    GameInitialized: Boolean;
    FSeconds: Integer;
    FMinutes: Integer;
    procedure MoveSnake;
    procedure GenerateFood;
    procedure CheckCollision;
    procedure CheckFood;
    procedure InitializeGame;
    procedure UpdateScore;
    procedure GenerateObstacles;
    procedure SaveRecord(const Score: Integer);
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

{$R *.dfm}

uses Unit1, Unit4;

procedure TForm3.BitBtn1Click(Sender: TObject);
begin
  Timer2.Enabled := False;
  Form3.Hide;
  Form1.Show;
end;

procedure TForm3.BitBtn2Click(Sender: TObject);
begin
  Form1.MediaPlayer1.Close;
  Timer2.Enabled := False;
  Close;
end;

procedure TForm3.BitBtn3Click(Sender: TObject);
var I: Integer;
begin
  InitializeGame;
  GenerateObstacles;
  for I := High(Snake) downto 1 do
    Snake[I] := Snake[I - 1];
  case Direction of
    dirUp: Dec(Snake[0].Y);
    dirDown: Inc(Snake[0].Y);
    dirLeft: Dec(Snake[0].X);
    dirRight: Inc(Snake[0].X);
  end;
end;

procedure TForm3.Timer2Timer(Sender: TObject);
begin
  MoveSnake;
  if GameInitialized then
  begin
    CheckCollision;
    CheckFood;
  end;
  DrawGrid1.Repaint;
end;

procedure TForm3.GenerateObstacles;   //��������� �����������
var
  I, J: Integer;
  Obstacle: TRect;
  Collision: Boolean;
begin
  Randomize;
  SetLength(Obstacles, SnakeBorder); // ��������, 5 �����������
  for I := 0 to High(Obstacles) do
  begin
    repeat
      Collision := False;
      Obstacle.Left := Random(DrawGrid1.ColCount - 1);
      Obstacle.Top := Random(DrawGrid1.RowCount - 1);
      Obstacle.Right := Obstacle.Left + 1;
      Obstacle.Bottom := Obstacle.Top + 1;

      // �������� �� ���������� � ������������ ������ ��� ���
      for J := 0 to High(Snake) do
        if PtInRect(Obstacle, Snake[J]) then
        begin
          Collision := True;
          Break;
        end;

      if PtInRect(Obstacle, Food) then
        Collision := True;

    until not Collision;
    Obstacles[I] := Obstacle;
  end;
end;


procedure TForm3.DrawGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  I: Integer;
begin
  with DrawGrid1.Canvas do
  begin
    // ��������� ������
    for I := 0 to High(Snake) do
    begin
      if (ACol = Snake[I].X) and (ARow = Snake[I].Y) then
      begin
        Brush.Color := SnakeColor;
        FillRect(Rect);
        Exit;
      end;
    end;

    // ��������� ���
    if (ACol = Food.X) and (ARow = Food.Y) then
    begin
      Brush.Color := clRed;
      FillRect(Rect);
    end
    else
    begin
      Brush.Color := clWhite;
      FillRect(Rect);
    end;

    // ��������� �����������
    for I := 0 to High(Obstacles) do
    begin
      if PtInRect(Obstacles[I], Point(ACol, ARow)) then
      begin
        Brush.Color := clGray;
        FillRect(Rect);
      end;
    end;
  end;
end;


procedure TForm3.InitializeGame;
begin
  SetLength(Snake, 3);
  Snake[0] := Point(14, 14); // ��������� ������� ������
  Direction := dirRight; // ��������� �����������
  GenerateFood;
  GenerateObstacles; // ��������� �����������
  Timer2.Enabled := True;
  Score := 0;
  UpdateScore;
  GameInitialized := True; // ���� ����������������
  if Form4.RadioButton1.Checked = True then SnakeSpeed := 400
  else
  if Form4.RadioButton2.Checked = True then SnakeSpeed := 200
  else
  if Form4.RadioButton3.Checked = True then SnakeSpeed := 100;
  Timer2.Interval := SnakeSpeed;
  if Form4.RadioButton4.Checked = True then SnakeColor := clGreen
  else
  if Form4.RadioButton5.Checked = True then SnakeColor := clLime
  else
  if Form4.RadioButton6.Checked = True then SnakeColor := clYellow;
  if Form4.RadioButton7.Checked = True then SnakeBorder := 0
  else
  if Form4.RadioButton8.Checked = True then SnakeBorder := 15
  else
  if Form4.RadioButton9.Checked = True then SnakeBorder := 30;

end;

procedure TForm3.FormCreate(Sender: TObject);
begin
  DrawGrid1.ColCount := 28;
  DrawGrid1.RowCount := 28;
  SetLength(Snake, 3);
  Snake[0] := Point(14, 14); // ��������� ������� ������
  Direction := dirRight; // ��������� �����������
  GenerateFood;
  GenerateObstacles; // ��������� �����������
  SnakeSpeed := 200;
  Timer2.Interval := 200; // �������� ������� (�������� ������)
  Timer2.Enabled := True;
  KeyPreview := True; // ��� ��������� ������� ������
  GameInitialized := False; // ���� ��� �� ����������������
end;


procedure TForm3.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_UP, ord('W'): if Direction <> dirDown then Direction := dirUp;
    VK_DOWN, ord('S'): if Direction <> dirUp then Direction := dirDown;
    VK_LEFT, ord('A'): if Direction <> dirRight then Direction := dirLeft;
    VK_RIGHT, ord('D'): if Direction <> dirLeft then Direction := dirRight;
  end;
end;

procedure TForm3.MoveSnake;
var
  I: Integer;
begin
  for I := High(Snake) downto 1 do
    Snake[I] := Snake[I - 1];
  case Direction of
    dirUp: Dec(Snake[0].Y);
    dirDown: Inc(Snake[0].Y);
    dirLeft: Dec(Snake[0].X);
    dirRight: Inc(Snake[0].X);
  end;
end;

procedure TForm3.N2Click(Sender: TObject);
begin
  close;
end;

procedure TForm3.N4Click(Sender: TObject);
begin
  ShowMessage('�����: �������� �������');
end;

procedure TForm3.N5Click(Sender: TObject);
begin
  ShowMessage('������: 1.0.0');
end;

procedure TForm3.N6Click(Sender: TObject);
begin
  ShellExecute(0,PChar('Open'),PChar('Help.chm'),nil,nil,SW_SHOW);
end;

procedure TForm3.CheckCollision;
var
  I: Integer;
begin
  // �������� ������������ � ���������
  if (Snake[0].X < 0) or (Snake[0].X >= DrawGrid1.ColCount) or
     (Snake[0].Y < 0) or (Snake[0].Y >= DrawGrid1.RowCount) then
  begin
    Timer2.Enabled := False;
    ShowMessage('���� ���������! ����: ' + IntToStr(Score));
    SaveRecord(Score); // ��������� ������ ��� ���������� ����
    Exit;
  end;

  // �������� ������������ � ����� �����
  for I := 1 to High(Snake) do
    if (Snake[0].X = Snake[I].X) and (Snake[0].Y = Snake[I].Y) then
    begin
      Timer2.Enabled := False;
      ShowMessage('�� ���������! ����: ' + IntToStr(Score));
      SaveRecord(Score); // ��������� ������ ��� ���������� ����
      Exit;
    end;

  // �������� ������������ � �������������
  for I := 0 to High(Obstacles) do
    if PtInRect(Obstacles[I], Snake[0]) then
    begin
      Timer2.Enabled := False;
      ShowMessage('�� ��������� � �����������! ����: ' + IntToStr(Score));
      SaveRecord(Score); // ��������� ������ ��� ���������� ����
      Exit;
    end;
end;


procedure TForm3.UpdateScore;
begin
  Label1.Caption := IntToStr(Score);
end;

procedure TForm3.CheckFood;
begin
  if (Snake[0].X = Food.X) and (Snake[0].Y = Food.Y) then
  begin
    SetLength(Snake, Length(Snake) + 1);
    Snake[High(Snake)] := Snake[High(Snake) - 1];
    GenerateFood;
    Inc(Score);
    UpdateScore;
    SnakeSpeed := Round(SnakeSpeed - 2);
    Timer2.Interval := SnakeSpeed;
  end;
end;

procedure TForm3.SaveRecord(const Score: Integer);
var
  FileName: string;
  FileHandle: TextFile;
begin
  FileName := ExtractFilePath(Application.ExeName) + 'snake_record.txt'; // ��� �����, � ������� ����� ��������� ������
  AssignFile(FileHandle, FileName);
  try
    // ���������, ���������� �� ����
    if FileExists(FileName) then
      Append(FileHandle) // ��������� ���� ��� ���������� ������
    else
      Rewrite(FileHandle); // ������� ����� ����
    // ���������� ������ � ����
    Writeln(FileHandle, Form4.Edit1.Text + '-' + IntToStr(Score));
  except
    on E: EInOutError do
    begin
      ShowMessage('��������� ������ ��� ������ � ������. �����������: ' + E.Message);
      Exit; // ������� �� ���������, ����� �������� ������� �������� ����������� �����
    end;
  end;
  // ��������� ���� � ����� finally
  try
    CloseFile(FileHandle);
  except
    on E: EInOutError do
    begin
      ShowMessage('������ ��� �������� �����. �����������: ' + E.Message);
    end;
  end;
end;


procedure TForm3.GenerateFood;
var
  FoodCollision: Boolean;
  I, J: Integer;
begin
  Randomize;
  repeat
    FoodCollision := False;
    Food.X := Random(DrawGrid1.ColCount);
    Food.Y := Random(DrawGrid1.RowCount);

    // �������� �� ���������� � ������������ ������
    for I := 0 to High(Snake) do
    begin
      if (Food.X = Snake[I].X) and (Food.Y = Snake[I].Y) then
      begin
        FoodCollision := True;
        Break;
      end;
    end;

    // �������� �� ���������� � ������������ �����������
    if not FoodCollision then
    begin
      for I := 0 to High(Obstacles) do
      begin
        for J := Obstacles[I].Left to Obstacles[I].Right do
          if (Food.X = J) and ((Food.Y = Obstacles[I].Top) or (Food.Y = Obstacles[I].Bottom)) then
          begin
            FoodCollision := True;
            Break;
          end;
        if FoodCollision then
          Break;
      end;
    end;

  until not FoodCollision;
end;


procedure TForm3.CreateParams(var Params: TCreateParams) ;// ��������� ��� ���� ����� ����� � ������ ����� �� ��������
begin
  inherited;
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
  Params.WndParent := 0;
end;

procedure TForm3.FormShow(Sender: TObject);
begin
  DrawGrid1.Repaint;

end;

end.

