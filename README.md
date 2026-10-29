# KioFocus

App Android de bem-estar digital. Quando você tenta abrir um app que te prende (Instagram, Reddit, YouTube...), o KioFocus aparece na frente, te faz esperar um tempo que **você mesmo define** e, enquanto isso, sugere algo melhor para fazer, como ler um ebook ou fazer a lição do Duolingo.

Leve, sem anúncios, sem conta e sem coletar nada.

## Como funciona

1. Você escolhe quais apps quer **barrar** e quanto tempo de espera cada um terá (padrão: 3 minutos).
2. Você escolhe os apps de **recomendação**, aqueles que prefere usar no lugar.
3. Ao abrir um app barrado, o KioFocus aparece com um timer e frases calmas. Se você tentar voltar para o app barrado antes do fim, ele te puxa de volta.
4. Quando o tempo acaba, você recebe uma **notificação**. O app fica liberado até você sair dele.

## Instalação

> Requer Android 5.0 ou mais novo.

1. Abra a página de [**Releases**](https://github.com/KioHype/KioFocus/releases/latest) pelo celular.
2. Baixe o arquivo `.apk` mais recente.
3. Abra o arquivo baixado. Se o Android avisar sobre "fonte desconhecida", toque em **Configurações** e permita a instalação para o navegador ou gerenciador de arquivos que você usou.
4. Toque em **Instalar**.

**Samsung:** se a instalação for bloqueada, desligue o recurso **Bloqueio automático (Auto Blocker)** em Configurações → Segurança e privacidade, ou permita a instalação de apps externos.

## Configuração inicial (obrigatória)

Sem estes passos o bloqueio não funciona.

### 1. Ativar o serviço de acessibilidade

É por ele que o KioFocus descobre qual app acabou de abrir.

1. Abra **Configurações → Acessibilidade**.
2. Procure **KioFocus**. O nome do menu varia por celular: "Aplicativos instalados", "Serviços instalados" ou "Aplicativos baixados". Se não achar, use a busca das Configurações.
3. Toque em **KioFocus**, ative a chave e confirme.

**Se a chave estiver cinza ou aparecer "Configuração restrita":** o Android bloqueia esse recurso em apps instalados fora da Play Store. Para liberar:

1. Mantenha o ícone do KioFocus pressionado → **Info do app** (ou Configurações → Apps → KioFocus).
2. Toque nos **três pontinhos** no canto superior direito.
3. Toque em **Permitir configurações restritas**.
4. Volte para Acessibilidade e ative o KioFocus.

### 2. Permitir notificações

Ao abrir o app pela primeira vez, aceite a permissão de notificação. Ela é usada para avisar que o tempo acabou.

### 3. Evitar que o sistema feche o serviço (recomendado)

Alguns celulares, principalmente Samsung, Xiaomi e Motorola, encerram serviços em segundo plano para economizar bateria.

- Vá em **Configurações → Apps → KioFocus → Bateria** e escolha **Irrestrito** (ou "Sem restrições").
- Na Samsung, confira também em Configurações → Bateria → Limites de uso em segundo plano que o KioFocus **não** está em "Apps em suspensão".

## Como usar

1. Abra o KioFocus. Na primeira vez, passe pelo mini tutorial e escolha a cor do app.
2. Na aba **Barrar**, toque em **+**, escolha o app e defina o tempo girando minutos e segundos.
3. Na aba **Recomendar**, toque em **+** e escolha os apps que prefere usar no lugar.
4. Pronto. Abra o app barrado para testar.

Para remover um app de qualquer lista, deslize o item para a esquerda. Para mudar o tempo, toque no relógio ao lado do app.

### Regras do timer

- O timer **não pode ser cancelado** pelo app.
- Ir para um app recomendado **não** reinicia o timer, e o tempo continua contando.
- Abrir **outro** app barrado no meio da espera reinicia o timer do primeiro.
- Quando o tempo acaba, o app fica liberado até você sair dele (o passe vale por até 10 minutos se você não abrir o app).

## Privacidade

- O serviço de acessibilidade só lê **qual app está na tela** (o nome do pacote). Ele **não** lê o conteúdo da tela, mensagens, senhas ou digitação.
- Tudo o que você configura fica salvo **só no seu celular**.
- O app não tem código que envie dados para a internet.
- A permissão para listar apps instalados serve apenas para você escolher quais barrar e recomendar.

## Limitações

- O KioFocus é uma ferramenta de autocontrole, **não** um controle parental. Dá para burlar desativando a acessibilidade ou desinstalando o app, e isso é proposital: a ideia é você escolher ficar.
- Testado em celular Samsung. Em outras marcas, as configurações de bateria e acessibilidade podem ter nomes diferentes.
- Só funciona em Android.

## Para desenvolvedores

Feito com Flutter. O bloqueio roda em um `AccessibilityService` nativo em Kotlin (`android/app/src/main/java/com/kiohype/kiofocus/`), que se comunica com a interface Flutter por um `MethodChannel`.

```
flutter pub get
flutter build apk --release
```

O APK sai em `build/app/outputs/flutter-apk/app-release.apk`.

Para trocar as frases motivacionais, edite `lib/services/phrases.dart`.

Contribuições e sugestões são bem-vindas, é só abrir uma issue.
