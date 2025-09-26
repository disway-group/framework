# LWC Starter (Build 2) – Cookbook

## 1) Tema (c/theme)
Use classes utilitárias:
```html
<article class="slds-card surface-card">
  <div class="slds-card__header bg-brand slds-p-around_small">
    <h2 class="slds-text-heading_small text-brand">Minha Tela</h2>
  </div>
</article>
```

## 2) Lookup (multi-select)
```html
<c-lookup-generic
  label="Contas"
  object-api-name="Account"
  fields="Name"
  subtitle-fields="Industry,Phone"
  multi
  max-selections="3"
  onselect={handleAccounts}>
</c-lookup-generic>
```
```js
handleAccounts(e){ console.log(e.detail.ids, e.detail.labels); }
```

## 3) Paginator
```html
<c-paginator page={page} total={total} page-size={pageSize} onchange={handlePage}></c-paginator>
```
```js
handlePage(e){ const { page, pageSize } = e.detail; /* refaça a query ao servidor */ }
```

## 4) Empty State
```html
<c-empty-state icon-name="utility:insert_tag_field" title="Nada aqui" description="Tente ajustar os filtros">
  <div slot="action">
    <lightning-button label="Criar novo" onclick={newRecord}></lightning-button>
  </div>
</c-empty-state>
```

## 5) File Uploader Pro
```html
<c-file-uploader-pro record-id={recordId} accept=".pdf,.png,.jpg"></c-file-uploader-pro>
```
Back-end:
- `FileApi.listFiles(recordId)`
- `FileApi.unlink(linkId)`

## 6) Chamada REST (Weather)
```apex
WeatherService.CurrentWeather cw = WeatherService.getCurrentWeather(-23.55, -46.63);
```

## 7) Padrões
- Utilize `c/api` para chamadas Apex com `{ ok, data, error }`.
- Centralize textos em `c/i18n`.
- Use `Database.queryWithBinds(..., USER_MODE)` para segurança.
- Testes: `SeeAllData=false`, mocks para callouts.
