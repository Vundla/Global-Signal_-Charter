# Page snapshot

```yaml
- generic [active] [ref=e1]:
  - generic [ref=e2]:
    - heading "500" [level=1] [ref=e3]
    - paragraph [ref=e4]: Internal Error
  - generic [ref=e8]:
    - generic [ref=e9]: "Cannot find module 'react' Require stack: - /workspaces/Global-Signal_-Charter/frontend/node_modules/rehackt/index.js - /workspaces/Global-Signal_-Charter/frontend/node_modules/@apollo/client/react/context/context.cjs - /workspaces/Global-Signal_-Charter/frontend/node_modules/@apollo/client/react/react.cjs - /workspaces/Global-Signal_-Charter/frontend/node_modules/@apollo/client/main.cjs"
    - generic [ref=e10]: "Error: Cannot find module 'react' Require stack: - /workspaces/Global-Signal_-Charter/frontend/node_modules/rehackt/index.js - /workspaces/Global-Signal_-Charter/frontend/node_modules/@apollo/client/react/context/context.cjs - /workspaces/Global-Signal_-Charter/frontend/node_modules/@apollo/client/react/react.cjs - /workspaces/Global-Signal_-Charter/frontend/node_modules/@apollo/client/main.cjs at Module._resolveFilename (node:internal/modules/cjs/loader:1421:15) at defaultResolveImpl (node:internal/modules/cjs/loader:1059:19) at resolveForCJSWithHooks (node:internal/modules/cjs/loader:1064:22) at Module._load (node:internal/modules/cjs/loader:1227:37) at TracingChannel.traceSync (node:diagnostics_channel:328:14) at wrapModuleLoad (node:internal/modules/cjs/loader:245:24) at Module.require (node:internal/modules/cjs/loader:1504:12) at require (node:internal/modules/helpers:152:16) at Object.<anonymous> (/workspaces/Global-Signal_-Charter/frontend/node_modules/rehackt/index.js:24:31) at Module._compile (node:internal/modules/cjs/loader:1761:14"
    - generic [ref=e11]:
      - text: Click outside, press Esc key, or fix the code to dismiss.
      - text: You can also disable this overlay by setting
      - code [ref=e12]: server.hmr.overlay
      - text: to
      - code [ref=e13]: "false"
      - text: in
      - code [ref=e14]: vite.config.ts
      - text: .
```