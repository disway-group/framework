export function isCnpjValid(cnpj) {
  return /^\d{14}$/.test((cnpj||'').replace(/\D/g,''));
}
export function onlyDigits(s) {
  return (s||'').replace(/\D/g, '');
}
