// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Ntfy Mirror';

  @override
  String get splashSubtitle => 'Encaminhamento de Mensagens Simplificado';

  @override
  String get initializing => 'Inicializando...';

  @override
  String get serviceActive => 'Serviço Ativo';

  @override
  String get serviceInactive => 'Serviço Inativo';

  @override
  String get serviceActiveDesc =>
      'Mensagens estão sendo monitoradas e encaminhadas';

  @override
  String get serviceInactiveDesc => 'Configure as opções e inicie o serviço';

  @override
  String get destinationSettings => 'Configurações de Destino';

  @override
  String get endpointUrl => 'URL do Endpoint';

  @override
  String get endpointHint => 'https://sua-api.exemplo.com/webhook';

  @override
  String get endpointHelper =>
      'Endpoint HTTP para receber os dados das mensagens';

  @override
  String get saveConfiguration => 'Salvar Configuração';

  @override
  String get configurationSaved => 'Configuração Salva';

  @override
  String get editPayloadTemplate => 'Editar Modelo de Payload';

  @override
  String get selectAppsToMonitor => 'Selecionar Apps para Monitorar';

  @override
  String get testConnectivityAuth => 'Testar conectividade + autenticação';

  @override
  String get testing => 'Testando...';

  @override
  String get waitingForEcho =>
      'Enviando notificação de teste — aguardando retorno...';

  @override
  String get setEndpointFirst => 'Defina o Endpoint primeiro';

  @override
  String get invalidUrl =>
      'URL inválida. Use https://sua-api.exemplo.com/webhook';

  @override
  String get onlyHttpsAllowed =>
      'Apenas HTTPS é permitido (HTTP apenas para localhost).';

  @override
  String get httpAuth => 'Autenticação HTTP';

  @override
  String get serviceControl => 'Controle do Serviço';

  @override
  String get checkingServiceStatus => 'Verificando status do serviço...';

  @override
  String get startMonitoringService => 'Iniciar Serviço de Monitoramento';

  @override
  String get stopService => 'Parar Serviço';

  @override
  String get smsObserver => 'Observador de SMS';

  @override
  String get smsObserverDesc => 'Monitorar SMS além de notificações';

  @override
  String get permissions => 'Permissões';

  @override
  String get notificationAccess => 'Acesso a Notificações';

  @override
  String get notificationAccessDesc => 'Necessário para capturar notificações';

  @override
  String get postNotifications => 'Postar Notificações';

  @override
  String get postNotificationsDesc =>
      'Permite que o app mostre notificações de status';

  @override
  String get readSms => 'Ler SMS';

  @override
  String get readSmsDesc => 'Opcional: Monitorar mensagens SMS';

  @override
  String get batteryOptimization => 'Otimização de Bateria';

  @override
  String get batteryOptimizationDesc => 'Evita que o Android pare o serviço';

  @override
  String get unrestrictedData => 'Dados Sem Restrição';

  @override
  String get unrestrictedDataDesc => 'Permitir acesso à rede em segundo plano';

  @override
  String get refreshPermissions => 'Atualizar Permissões';

  @override
  String get granted => 'Concedido';

  @override
  String get optional => 'Opcional';

  @override
  String get required => 'Obrigatório';

  @override
  String get settings => 'Configurações';

  @override
  String get grant => 'Conceder';

  @override
  String get about => 'Sobre';

  @override
  String get openSourceProject => 'Projeto Open Source';

  @override
  String get starOnGithub => 'Dar Estrela no GitHub';

  @override
  String get reportIssues => 'Reportar Problemas';

  @override
  String get queue => 'Fila';

  @override
  String get logs => 'Logs';

  @override
  String get sendingTestWaiting =>
      'Enviando notificação de teste — aguardando retorno...';

  @override
  String get httpAuthentication => 'Autenticação HTTP';

  @override
  String get monitorSmsInAddition =>
      'Monitorar mensagens SMS além de notificações';

  @override
  String get requiredToCaptureNotifications =>
      'Obrigatório para capturar notificações';

  @override
  String get allowShowStatusNotifications =>
      'Permitir exibir notificações de status';

  @override
  String get optionalMonitorSms => 'Opcional: Monitorar mensagens SMS';

  @override
  String get preventAndroidStopping => 'Evitar que o Android pare o serviço';

  @override
  String get allowBackgroundNetwork =>
      'Permitir acesso à rede em segundo plano';

  @override
  String get configureStartService =>
      'Configure as definições e inicie o serviço';

  @override
  String get messagesMonitored =>
      'Mensagens estão sendo monitoradas e encaminhadas';

  @override
  String get validationSuccess =>
      'Validação OK — a mensagem de teste foi enviada ao endpoint e recebida de volta.';

  @override
  String get validationSendFailed =>
      'Não foi possível enviar a mensagem de teste ao endpoint.';

  @override
  String get validationTimeout =>
      'Mensagem de teste enviada, mas não voltou a tempo. Verifique o Acesso a Notificações, o serviço e os apps selecionados.';

  @override
  String get validationNotConfirmed =>
      'Mensagem de teste enviada, mas não confirmada.';

  @override
  String get validationAuthFailed =>
      'Falha na autenticação (HTTP 401/403) — verifique as credenciais nas configurações.';

  @override
  String get validationEndpointUnreachable =>
      'O endpoint rejeitou ou está inacessível — verifique a URL e a rede.';

  @override
  String get validationListenerNoAccess =>
      'O acesso a notificações não está concedido — conceda para que as notificações possam ser captadas.';

  @override
  String get validationListenerNotRunning =>
      'O acesso a notificações está concedido, mas o listener não está em execução. Permita a inicialização automática e bateria irrestrita (MIUI/HyperOS) e depois desative e ative o Acesso a Notificações.';

  @override
  String get validationNotificationsDisabled =>
      'A permissão de notificações não está concedida — habilite as notificações do Ntfy Mirror.';

  @override
  String get validationTestNotificationFailed =>
      'Não foi possível iniciar a notificação de teste local.';

  @override
  String validationTestNotificationFailedDetail(String detail) {
    return 'Não foi possível iniciar a notificação de teste local ($detail).';
  }

  @override
  String get validationTestNotificationUnsupported =>
      'Esta build não suporta notificações de teste locais.';

  @override
  String get authMissingToken => 'Digite o token de acesso.';

  @override
  String get authMissingHeaderName => 'Digite o nome do cabeçalho.';

  @override
  String get authMissingApiKey => 'Digite o valor da chave de API.';

  @override
  String get authMissingUsername => 'Digite o nome de usuário.';

  @override
  String get authMissingPassword => 'Digite a senha.';

  @override
  String get useNtfyStyle => 'Usar entrega estilo ntfy';

  @override
  String get ntfyStyleEnabled => 'Estilo ntfy ativado';

  @override
  String get templateCannotBeEmpty =>
      'O modelo não pode estar vazio quando o estilo ntfy estiver desativado';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appTitle => 'Ntfy Mirror';

  @override
  String get splashSubtitle => 'Encaminhamento de Mensagens Simplificado';

  @override
  String get initializing => 'Inicializando...';

  @override
  String get serviceActive => 'Serviço Ativo';

  @override
  String get serviceInactive => 'Serviço Inativo';

  @override
  String get serviceActiveDesc =>
      'Mensagens estão sendo monitoradas e encaminhadas';

  @override
  String get serviceInactiveDesc => 'Configure as opções e inicie o serviço';

  @override
  String get destinationSettings => 'Configurações de Destino';

  @override
  String get endpointUrl => 'URL do Endpoint';

  @override
  String get endpointHint => 'https://sua-api.exemplo.com/webhook';

  @override
  String get endpointHelper =>
      'Endpoint HTTP para receber os dados das mensagens';

  @override
  String get saveConfiguration => 'Salvar Configuração';

  @override
  String get configurationSaved => 'Configuração Salva';

  @override
  String get editPayloadTemplate => 'Editar Modelo de Payload';

  @override
  String get selectAppsToMonitor => 'Selecionar Apps para Monitorar';

  @override
  String get testConnectivityAuth => 'Testar conectividade + autenticação';

  @override
  String get testing => 'Testando...';

  @override
  String get waitingForEcho =>
      'Enviando notificação de teste — aguardando retorno...';

  @override
  String get setEndpointFirst => 'Defina o Endpoint primeiro';

  @override
  String get invalidUrl =>
      'URL inválida. Use https://sua-api.exemplo.com/webhook';

  @override
  String get onlyHttpsAllowed =>
      'Apenas HTTPS é permitido (HTTP apenas para localhost).';

  @override
  String get httpAuth => 'Autenticação HTTP';

  @override
  String get serviceControl => 'Controle do Serviço';

  @override
  String get checkingServiceStatus => 'Verificando status do serviço...';

  @override
  String get startMonitoringService => 'Iniciar Serviço de Monitoramento';

  @override
  String get stopService => 'Parar Serviço';

  @override
  String get smsObserver => 'Observador de SMS';

  @override
  String get smsObserverDesc => 'Monitorar SMS além de notificações';

  @override
  String get permissions => 'Permissões';

  @override
  String get notificationAccess => 'Acesso a Notificações';

  @override
  String get notificationAccessDesc => 'Necessário para capturar notificações';

  @override
  String get postNotifications => 'Postar Notificações';

  @override
  String get postNotificationsDesc =>
      'Permite que o app mostre notificações de status';

  @override
  String get readSms => 'Ler SMS';

  @override
  String get readSmsDesc => 'Opcional: Monitorar mensagens SMS';

  @override
  String get batteryOptimization => 'Otimização de Bateria';

  @override
  String get batteryOptimizationDesc => 'Evita que o Android pare o serviço';

  @override
  String get unrestrictedData => 'Dados Sem Restrição';

  @override
  String get unrestrictedDataDesc => 'Permitir acesso à rede em segundo plano';

  @override
  String get refreshPermissions => 'Atualizar Permissões';

  @override
  String get granted => 'Concedido';

  @override
  String get optional => 'Opcional';

  @override
  String get required => 'Obrigatório';

  @override
  String get settings => 'Configurações';

  @override
  String get grant => 'Conceder';

  @override
  String get about => 'Sobre';

  @override
  String get openSourceProject => 'Projeto Open Source';

  @override
  String get starOnGithub => 'Dar Estrela no GitHub';

  @override
  String get reportIssues => 'Reportar Problemas';

  @override
  String get queue => 'Fila';

  @override
  String get logs => 'Logs';

  @override
  String get sendingTestWaiting =>
      'Enviando notificação de teste — aguardando retorno...';

  @override
  String get httpAuthentication => 'Autenticação HTTP';

  @override
  String get monitorSmsInAddition =>
      'Monitorar mensagens SMS além de notificações';

  @override
  String get requiredToCaptureNotifications =>
      'Obrigatório para capturar notificações';

  @override
  String get allowShowStatusNotifications =>
      'Permitir exibir notificações de status';

  @override
  String get optionalMonitorSms => 'Opcional: Monitorar mensagens SMS';

  @override
  String get preventAndroidStopping => 'Evitar que o Android pare o serviço';

  @override
  String get allowBackgroundNetwork =>
      'Permitir acesso à rede em segundo plano';

  @override
  String get configureStartService =>
      'Configure as definições e inicie o serviço';

  @override
  String get messagesMonitored =>
      'Mensagens estão sendo monitoradas e encaminhadas';

  @override
  String get validationSuccess =>
      'Validação OK — a mensagem de teste foi enviada ao endpoint e recebida de volta.';

  @override
  String get validationSendFailed =>
      'Não foi possível enviar a mensagem de teste ao endpoint.';

  @override
  String get validationTimeout =>
      'Mensagem de teste enviada, mas não voltou a tempo. Verifique o Acesso a Notificações, o serviço e os apps selecionados.';

  @override
  String get validationNotConfirmed =>
      'Mensagem de teste enviada, mas não confirmada.';

  @override
  String get validationAuthFailed =>
      'Falha na autenticação (HTTP 401/403) — verifique as credenciais nas configurações.';

  @override
  String get validationEndpointUnreachable =>
      'O endpoint rejeitou ou está inacessível — verifique a URL e a rede.';

  @override
  String get validationListenerNoAccess =>
      'O acesso a notificações não está concedido — conceda para que as notificações possam ser captadas.';

  @override
  String get validationListenerNotRunning =>
      'O acesso a notificações está concedido, mas o listener não está em execução. Permita a inicialização automática e bateria irrestrita (MIUI/HyperOS) e depois desative e ative o Acesso a Notificações.';

  @override
  String get validationNotificationsDisabled =>
      'A permissão de notificações não está concedida — habilite as notificações do Ntfy Mirror.';

  @override
  String get validationTestNotificationFailed =>
      'Não foi possível iniciar a notificação de teste local.';

  @override
  String validationTestNotificationFailedDetail(String detail) {
    return 'Não foi possível iniciar a notificação de teste local ($detail).';
  }

  @override
  String get validationTestNotificationUnsupported =>
      'Esta build não suporta notificações de teste locais.';

  @override
  String get authMissingToken => 'Digite o token de acesso.';

  @override
  String get authMissingHeaderName => 'Digite o nome do cabeçalho.';

  @override
  String get authMissingApiKey => 'Digite o valor da chave de API.';

  @override
  String get authMissingUsername => 'Digite o nome de usuário.';

  @override
  String get authMissingPassword => 'Digite a senha.';

  @override
  String get useNtfyStyle => 'Usar entrega estilo ntfy';

  @override
  String get ntfyStyleEnabled => 'Estilo ntfy ativado';

  @override
  String get templateCannotBeEmpty =>
      'O modelo não pode estar vazio quando o estilo ntfy estiver desativado';
}
