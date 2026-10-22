# ReservaFans — App Flutter (Android + Web)

Aplicativo em **Flutter e Dart** para reservar salas, auditórios e equipamentos da FANS.
Consome a **API REST do ReservaFans** (Node.js + Express + SQLite), que é o banco de dados real do sistema.
Mesmo código para **Android** e **navegador**.

## Como rodar

### 1) Subir a API (banco de dados real)
Na pasta `reservafans-api`:
```bash
npm install
npm run seed:demo     # cria o banco com dados de exemplo
npm start             # http://localhost:3000
```
Contas: administrador `admin@fans.edu.br / admin123` · usuário `aluno.teste@fans.edu.br / teste123`.

### 2) Preparar o projeto Flutter (uma vez, após clonar)
Com o Flutter instalado (`flutter doctor`), na pasta deste projeto:
```bash
dart tool/setup.dart
```
O script gera as pastas `android/` e `web/`, libera internet/HTTP no Android e roda `flutter pub get`.
Depois faça commit das pastas geradas (`git add . && git commit -m "Plataformas Android e Web"`).

### 3) Executar
```bash
flutter run -d chrome            # navegador
flutter run -d <id-do-android>   # emulador ou celular (flutter devices)
flutter test                     # testes unitários
```

### Endereço da API
Padrão: navegador `http://localhost:3000/api` · emulador Android `http://10.0.2.2:3000/api`.
Em **celular físico**, na tela de login toque em **Configurar servidor** e informe `http://IP-DO-COMPUTADOR:3000/api`
(celular e computador na mesma rede). O endereço escolhido fica salvo no aparelho.

## Requisitos da prova × onde estão

| Requisito | Implementação |
|---|---|
| Multiplataforma (Android + web) | Um único código; plataformas `android` e `web`. Sem pacotes exclusivos de uma plataforma (`dart:io` não é usado). |
| Flutter e Dart | Todo o app em `lib/` (Material 3). |
| Comunicação HTTP | `lib/services/api_client.dart` (pacote `http`: GET, POST, PUT, PATCH, DELETE, multipart) e `reservafans_api.dart` (um método por endpoint). |
| Acesso a banco de dados | A API grava e lê no SQLite (Sequelize). O app não usa listas em memória nem dados fixos. |
| Persistência | Reservas, recursos e categorias ficam no banco; a **sessão** (token) fica em `shared_preferences` — ao fechar e reabrir, o app continua logado (`state/auth_state.dart`). |
| Consulta | Catálogo com estoque, filtro por categoria, minhas reservas, painel do admin, devoluções. |
| Cadastro | Nova reserva (única ou por período), cadastro/edição de recurso com foto, nova categoria. |
| Atualização da interface | Após cadastrar, cancelar ou devolver, as telas recarregam da API; puxar para atualizar. |
| Validação | `utils/validators.dart`: e-mail, senha, campos obrigatórios, quantidade inteira ≥ 0, horário de aula 18:50–22:25, devolução depois do início, datas do período. |
| Tratamento de erros | Falha de conexão, timeout e erros da API viram mensagens (`ApiException`); telas mostram `ErrorView` com "Tentar novamente", faixas de erro e SnackBars; sessão expirada volta ao login. |
| Arquitetura | `models/` · `services/` · `state/` · `screens/` · `widgets/` · `utils/` · `config/`. |

## Níveis de acesso
- **Usuário:** catálogo, reservar, minhas reservas, cancelar as próprias.
- **Administrador:** painel, gestão de recursos e categorias (com foto), controle de devoluções.
O servidor também valida o perfil (resposta 403 para usuário comum em rotas de admin).

## Roteiro de teste (Android e navegador)
1. Login com a conta de usuário → catálogo carrega itens da API.
2. Abrir um item → reserva única (data, 18:50–22:25) → confirmar → aparece em *Minhas reservas*.
3. Tentar horário fora de 18:50–22:25 → o formulário bloqueia; tentar esgotar o estoque → erro da API exibido.
4. Fechar e reabrir o app → continua logado e os dados continuam lá.
5. Parar a API e tocar em "Tentar novamente" → mensagem de falha de conexão.
6. Entrar como admin → cadastrar recurso com foto e nova categoria; marcar devolução.

## Entrega
Repositório Git com este projeto completo:
```bash
git remote add origin <URL-do-seu-repositorio>
git push -u origin main
```
