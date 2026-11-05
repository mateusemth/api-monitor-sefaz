program Ibpt;

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Classes, System.Net.HttpClient, System.Net.URLClient,
  System.Generics.Collections, System.NetEncoding;

const
  TodasUFs = 'AC,AL,AP,AM,BA,CE,DF,ES,GO,MA,MT,MS,MG,PA,PB,PR,PE,PI,RJ,RN,RS,RO,RR,SC,SP,SE,TO';

var
  Token, Entrada, Destino, UF, Normalizada, Selecionadas: string;
  Lista: TArray<string>;
  Usadas: TDictionary<string, Boolean>;
  Cliente: THTTPClient;
  Resposta: IHTTPResponse;
  Dados: TMemoryStream;
  Arquivo: TFileStream;
  Assinatura: array[0..3] of Byte;
begin
  try
    Token := GetEnvironmentVariable('MONITOR_FISCAL_API_KEY');
    if Token = '' then raise Exception.Create('Configure a variável MONITOR_FISCAL_API_KEY.');
    Entrada := TodasUFs;
    Destino := 'tabelas-ibpt.zip';
    if ParamCount >= 1 then Entrada := ParamStr(1);
    if ParamCount >= 2 then Destino := ParamStr(2);
    Lista := Entrada.Split([',']);
    Usadas := TDictionary<string, Boolean>.Create;
    try
      Selecionadas := '';
      for UF in Lista do
      begin
        Normalizada := UpperCase(Trim(UF));
        if (Pos(',' + Normalizada + ',', ',' + TodasUFs + ',') = 0) or (Normalizada = '') or Usadas.ContainsKey(Normalizada) then
          raise Exception.Create('Informe UFs válidas, sem repetição.');
        Usadas.Add(Normalizada, True);
        if Selecionadas <> '' then Selecionadas := Selecionadas + ',';
        Selecionadas := Selecionadas + Normalizada;
      end;
    finally
      Usadas.Free;
    end;
    Cliente := THTTPClient.Create;
    Dados := TMemoryStream.Create;
    try
      Cliente.ConnectionTimeout := 120000;
      Cliente.ResponseTimeout := 120000;
      Cliente.CustomHeaders['x-api-token'] := Token;
      Resposta := Cliente.Get('https://fiscal.mateusemth.dev/api/ibpt/latest?uf=' +
        TNetEncoding.URL.Encode(Selecionadas), Dados);
      if (Resposta.StatusCode < 200) or (Resposta.StatusCode >= 300) then
        raise Exception.CreateFmt('Falha ao consultar IBPT (HTTP %d).', [Resposta.StatusCode]);
      Dados.Position := 0;
      if (Dados.Size < 4) or (Dados.Read(Assinatura, 4) <> 4) or
         (Assinatura[0] <> $50) or (Assinatura[1] <> $4B) or
         (Assinatura[2] <> 3) or (Assinatura[3] <> 4) then
        raise Exception.Create('A resposta não é um ZIP válido.');
      if FileExists(Destino) then raise Exception.Create('O arquivo de destino já existe.');
      Arquivo := TFileStream.Create(Destino, fmCreate or fmShareExclusive);
      try
        Dados.Position := 0;
        Arquivo.CopyFrom(Dados, Dados.Size);
      finally
        Arquivo.Free;
      end;
      Writeln(Format('ZIP IBPT salvo em %s (%d bytes).', [Destino, Dados.Size]));
    finally
      Dados.Free;
      Cliente.Free;
    end;
  except
    on E: Exception do begin Writeln('Erro: ' + E.Message); ExitCode := 1; end;
  end;
end.
