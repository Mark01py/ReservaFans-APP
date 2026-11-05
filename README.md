# ReservaFans — Sistema de Reservas

Aplicativo multiplataforma desenvolvido com Flutter e Dart para gerenciamento de reservas de salas, auditórios e equipamentos da FANS.

O sistema utiliza uma API REST desenvolvida em Node.js e Express, com persistência de dados em banco SQLite. A aplicação está disponível para Android e navegadores Web.

## Tecnologias utilizadas

- Flutter e Dart
- Node.js e Express
- SQLite e Sequelize
- API REST
- SharedPreferences
- Git e GitHub
- Railway para hospedagem da API

## API de produção

A API está hospedada na Railway:

- Endereço: https://reservafans-api-production.up.railway.app
- Endpoint de saúde: https://reservafans-api-production.up.railway.app/api/health
- Base da API: https://reservafans-api-production.up.railway.app/api

O aplicativo utiliza esse endereço como configuração padrão.

Repositório do backend:

https://github.com/Mark01py/ReservaFans-Api

## Como executar o projeto

### 1. Requisitos

- Flutter instalado e configurado.
- Dart SDK.
- Android Studio e Android SDK para execução e compilação Android.
- Git.

### 2. Obter as dependências

Na pasta do projeto, execute:

```bash
flutter pub get
```

### 3. Executar a aplicação

Para executar no navegador:

```bash
flutter run -d chrome
```

Para executar em um dispositivo Android:

```bash
flutter devices
flutter run -d ID_DO_DISPOSITIVO
```

Para executar os testes:

```bash
flutter test
```

## Configuração do servidor

Por padrão, o aplicativo utiliza a API de produção hospedada na Railway.

A tela de login disponibiliza a opção **Configurar servidor**, permitindo informar outro endereço de API quando necessário, como em ambientes locais de desenvolvimento.

## Funcionalidades

### Usuário

- Visualização do catálogo de recursos disponíveis.
- Consulta de categorias e estoque.
- Realização de reservas individuais.
- Realização de reservas por período.
- Consulta das próprias reservas.
- Cancelamento de reservas próprias.

### Administrador

- Painel administrativo.
- Cadastro e edição de recursos.
- Inclusão de fotografias dos recursos.
- Cadastro e gerenciamento de categorias.
- Consulta das reservas.
- Controle de retirada e devolução de recursos.

O controle de permissões também é realizado pela API, que restringe as operações administrativas aos usuários autorizados.

## Requisitos acadêmicos e implementação

| Requisito | Implementação |
|---|---|
| Multiplataforma | Aplicação Flutter para Android e Web. |
| Flutter e Dart | Código-fonte organizado na pasta `lib/`. |
| Comunicação HTTP | `services/api_client.dart` e `reservafans_api.dart`. |
| Banco de dados | Persistência realizada pela API utilizando SQLite e Sequelize. |
| Persistência de sessão | Token armazenado por meio do SharedPreferences. |
| Consulta | Catálogo, estoque, reservas e painel administrativo. |
| Cadastro | Reservas, recursos e categorias. |
| Atualização | Dados atualizados a partir das respostas da API. |
| Validação | Validações de formulários, datas, horários e quantidades. |
| Tratamento de erros | Tratamento de falhas de conexão, timeout e respostas da API. |
| Arquitetura | Organização em `models/`, `services/`, `state/`, `screens/`, `widgets/`, `utils/` e `config/`. |

## Contas para testes

Foram disponibilizadas as seguintes contas de teste:

| Perfil | E-mail |
|---|---|
| Administrador | admin@fans.edu.br |
| Usuário | professor.teste@fans.edu.br |

As senhas devem ser fornecidas separadamente aos responsáveis pela avaliação. Não são disponibilizadas neste repositório.

## Roteiro de testes

1. Acessar o aplicativo com uma conta de usuário.
2. Verificar o carregamento do catálogo de recursos.
3. Realizar uma reserva e conferir sua inclusão em Minhas Reservas.
4. Testar as validações de horários e disponibilidade.
5. Fechar e reabrir o aplicativo para verificar a persistência da sessão.
6. Acessar com uma conta administrativa.
7. Cadastrar ou editar recursos e categorias.
8. Verificar as operações de retirada e devolução.

## Gerar o APK

Para gerar o APK localmente, utilize:

```bash
flutter build apk --release
```

O arquivo será gerado em:

```text
build/app/outputs/flutter-apk/app-release.apk
```

A compilação de produção utiliza a configuração de assinatura Android. A chave privada e os arquivos de configuração de assinatura não fazem parte deste repositório.

### Compilação automática pelo GitHub Actions

O projeto possui um workflow em:

```text
.github/workflows/build-apk.yml
```

Após o envio de alterações para a branch `main`, o GitHub Actions executa automaticamente:

1. Configuração do ambiente Java e Flutter.
2. Instalação das dependências.
3. Configuração da assinatura Android por meio dos GitHub Secrets.
4. Execução dos testes.
5. Compilação do APK em versão release.
6. Disponibilização do APK como artefato da execução.

Para baixar o arquivo:

1. Acesse a aba **Actions** do repositório.
2. Abra a execução do workflow **Gerar APK**.
3. Localize a seção **Artifacts**.
4. Baixe o artefato `reservafans-apk`.

## Estrutura do projeto

```text
reservafans_app/
├── .github/
│   └── workflows/
│       └── build-apk.yml
├── android/
├── assets/
├── lib/
│   ├── config/
│   ├── models/
│   ├── screens/
│   ├── services/
│   ├── state/
│   ├── utils/
│   └── widgets/
├── test/
├── web/
├── windows/
├── pubspec.yaml
└── README.md
```

## Repositório

O código-fonte do aplicativo é mantido no GitHub.

A versão Web e o respectivo endereço público serão disponibilizados após a conclusão da publicação.

---

**ReservaFans — Sistema de Reservas da FANS.**