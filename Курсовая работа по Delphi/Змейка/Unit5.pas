unit Unit5;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.Imaging.pngimage,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, ShellAPI;

type
  TForm5 = class(TForm)
    Image1: TImage;
    Memo1: TMemo;
    BitBtn1: TBitBtn;
    Image2: TImage;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N6: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
  private
    procedure LoadRecords;
    procedure SortRecords;
  public
    { Public declarations }
  end;

var
  Form5: TForm5;

implementation

Uses Unit1;

{$R *.dfm}

procedure TForm5.BitBtn1Click(Sender: TObject);
var
  FileName: string;
  FileHandle: TextFile;
begin
  FileName := ExtractFilePath(Application.ExeName) + 'snake_record.txt'; // имя файла, который будем очищать
  AssignFile(FileHandle, FileName);
  try
    try
      Rewrite(FileHandle); // Открываем файл в режиме записи, чтобы очистить его
    except
      on E: EInOutError do
      begin
        ShowMessage('Произошла ошибка при открытии файла для записи. Подробности: ' + E.Message);
        Exit; // Выходим из процедуры, чтобы избежать попытки закрытия неоткрытого файла
      end;
    end;
  finally
    try
      CloseFile(FileHandle);
    except
      on E: EInOutError do
      begin
        ShowMessage('Произошла ошибка при закрытии файла. Подробности: ' + E.Message);
      end;
    end;
  end;

  Memo1.Clear; // Очищаем Memo1
end;


procedure TForm5.BitBtn2Click(Sender: TObject);
begin
  Form5.Hide;
  Form1.Show;
end;

procedure TForm5.FormShow(Sender: TObject);
begin
  LoadRecords; // Загружаем и сортируем записи при показе формы
end;

procedure TForm5.LoadRecords;
var
  FileName: string;
  FileHandle: TextFile;
  Line: string;
begin
  FileName := ExtractFilePath(Application.ExeName) + 'snake_record.txt';
  if FileExists(FileName) then
  begin
    Memo1.Clear;
    AssignFile(FileHandle, FileName);
    try
      Reset(FileHandle); // Открываем файл для чтения
      try
        while not EOF(FileHandle) do
        begin
          ReadLn(FileHandle, Line);
          Memo1.Lines.Add(Line);
        end;
      finally
        CloseFile(FileHandle); // Закрываем файл в любом случае
      end;
    except
      on E: EInOutError do
        ShowMessage('Произошла ошибка при чтении файла. Подробности: ' + E.Message);
    end;

    SortRecords; // Сортируем записи после загрузки
  end
  else
  begin
    ShowMessage('Файл не найден: ' + FileName);
  end;
end;


procedure TForm5.N2Click(Sender: TObject);
begin
  Close;
end;

procedure TForm5.N4Click(Sender: TObject);
begin
  ShowMessage('Автор: Дашкевич Евгений');
end;

procedure TForm5.N5Click(Sender: TObject);
begin
  ShowMessage('Версия: 1.0.0');
end;

procedure TForm5.N6Click(Sender: TObject);
begin
  ShellExecute(0,PChar('Open'),PChar('Help.chm'),nil,nil,SW_SHOW);
end;

procedure TForm5.SortRecords;
var
  i, j: Integer;
  Temp: string;
  Score1, Score2: Integer;
begin
  // Простая сортировка пузырьком для примера; замените на более эффективный алгоритм, если нужно
  for i := 0 to Memo1.Lines.Count - 2 do
  begin
    for j := Memo1.Lines.Count - 2 downto i do
    begin
      // Получаем числовые значения результатов для сравнения
      Score1 := StrToIntDef(Trim(Copy(Memo1.Lines[j], Pos('-', Memo1.Lines[j]) + 1, MaxInt)), 0);
      Score2 := StrToIntDef(Trim(Copy(Memo1.Lines[j+1], Pos('-', Memo1.Lines[j+1]) + 1, MaxInt)), 0);

      // Сортируем по убыванию
      if Score1 < Score2 then
      begin
        Temp := Memo1.Lines[j];
        Memo1.Lines[j] := Memo1.Lines[j+1];
        Memo1.Lines[j+1] := Temp;
      end;
    end;
  end;
end;



end.

