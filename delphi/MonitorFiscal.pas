unit MonitorFiscal;

interface

uses
  System.SysUtils, System.Classes, REST.Types, REST.Client, Data.Bind.Components,
  Data.Bind.ObjectScope, System.JSON;

type
  TMonitorFiscalAPI = class
  private
    FBaseURL: string;
    FAPIKey: string;
    function ExecuteRequest(const AEndpoint: string): string;
  public
    constructor Create(const AAPIKey: string);
    procedure VerifyToken;
    procedure CheckStatus(const APortal: string = 'nfe');
    procedure GetRecentDocuments(const APortal: string = 'nfe'; const ALimit: Integer = 5);
    procedure GetRealtimeDocuments(const APortal: string = 'nfe');
    procedure GetNotifications(const AIncludeRead: Boolean = False);
    procedure GetComparisons(const APortal: string = 'nfe'; const ALimit: Integer = 3);
  end;

implementation

constructor TMonitorFiscalAPI.Create(const AAPIKey: string);
begin
  if AAPIKey = 'SUA_API_KEY_AQUI' then
    raise Exception.Create('ERRO: A autenticacao e obrigatoria. Configure sua API_KEY.');
    
  FBaseURL := 'https://fiscal.mateusemth.dev/api';
  FAPIKey := AAPIKey;
end;

function TMonitorFiscalAPI.ExecuteRequest(const AEndpoint: string): string;
var
  LClient: TRESTClient;
  LRequest: TRESTRequest;
  LResponse: TRESTResponse;
begin
  LClient := TRESTClient.Create(FBaseURL + AEndpoint);
  LRequest := TRESTRequest.Create(nil);
  LResponse := TRESTResponse.Create(nil);
  try
    LRequest.Client := LClient;
    LRequest.Response := LResponse;
    LRequest.Method := rmGET;
    LRequest.Params.AddItem('Authorization', 'Bearer ' + FAPIKey, pkHTTPHEADER, [poDoNotEncode]);

    LRequest.Execute;
    Result := LResponse.Content;
  finally
    LClient.Free;
    LRequest.Free;
    LResponse.Free;
  end;
end;

procedure TMonitorFiscalAPI.VerifyToken;
begin
  Writeln(#10'--- Verificando API Key ---');
  Writeln(ExecuteRequest('/fiscal-api-keys/scopes'));
end;

procedure TMonitorFiscalAPI.CheckStatus(const APortal: string);
begin
  Writeln(#10'--- Status do Portal: ' + UpperCase(APortal) + ' ---');
  Writeln(ExecuteRequest('/fiscal-status?portal=' + APortal));
end;

procedure TMonitorFiscalAPI.GetRecentDocuments(const APortal: string; const ALimit: Integer);
begin
  Writeln(#10'--- Ultimos Documentos: ' + UpperCase(APortal) + ' ---');
  Writeln(ExecuteRequest('/fiscal-documents?portal=' + APortal + '&limit=' + IntToStr(ALimit)));
end;

procedure TMonitorFiscalAPI.GetRealtimeDocuments(const APortal: string);
begin
  Writeln(#10'--- Busca em Tempo Real (Scraper): ' + UpperCase(APortal) + ' ---');
  Writeln(ExecuteRequest('/fiscal-api?portal=' + APortal));
end;

procedure TMonitorFiscalAPI.GetNotifications(const AIncludeRead: Boolean);
var
  LParam: string;
begin
  Writeln(#10'--- Notificacoes do Sistema ---');
  if AIncludeRead then LParam := 'true' else LParam := 'false';
  Writeln(ExecuteRequest('/fiscal-notifications?includeRead=' + LParam));
end;

procedure TMonitorFiscalAPI.GetComparisons(const APortal: string; const ALimit: Integer);
begin
  Writeln(#10'--- Comparacoes (Diffs/IA): ' + UpperCase(APortal) + ' ---');
  Writeln(ExecuteRequest('/fiscal-document-comparisons?portal=' + APortal + '&limit=' + IntToStr(ALimit)));
end;

end.
