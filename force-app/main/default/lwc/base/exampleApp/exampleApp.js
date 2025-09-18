import { LightningElement, track } from 'lwc';
import { callApex } from 'c/api';
import { isCnpjValid, onlyDigits } from 'c/formUtils';
import { showToast } from 'c/toast';
import { i18n } from 'c/i18n';
import getSampleRows from '@salesforce/apex/ExampleApi.getSampleRows';

export default class ExampleApp extends LightningElement {
  title = i18n.exampleTitle;
  loading = false;

  @track rows = [];
  columns = [
    { label: 'Id', fieldName: 'id' },
    { label: 'Nome', fieldName: 'name' },
    { label: 'CNPJ', fieldName: 'cnpj' },
    { type: 'action', typeAttributes: { rowActions: [{ label: 'Ver', name: 'view' }] } }
  ];

  // pagination
  page = 1; pageSize = 10;
  get total(){ return this.rows.length; }
  get pagedRows(){ const s=(this.page-1)*this.pageSize; return this.rows.slice(s, s+this.pageSize); }
  handlePageChange(e){ this.page = e.detail.page; this.pageSize = e.detail.pageSize; }

  cnpj = '';
  confirmOpen = false;
  detailOpen = false;
  selected = null;

  demoRecordId = '001000000000001AAA'; // dummy recordId for fileUploader demo

  handleCnpjChange(e){ this.cnpj = onlyDigits(e.target.value); }

  async handleSearch(){
    if(!isCnpjValid(this.cnpj)){
      showToast(this, 'Aviso', 'CNPJ inválido (use 14 dígitos)', 'warning'); return;
    }
    this.loading = true;
    const res = await callApex(getSampleRows, { cnpj: this.cnpj });
    this.loading = false;
    if(res.ok){
      this.rows = res.data || []; this.page = 1;
      if(!this.rows.length) showToast(this, 'Info', 'Nenhum registro encontrado', 'info');
    } else { showToast(this, 'Erro', res.error, 'error'); }
  }

  handleRowAction(event){
    const { action, row } = event.detail;
    if(action.name === 'view'){ this.selected = row; this.detailOpen = true; }
  }
  closeDetails(){ this.detailOpen = false; this.selected = null; }

  openConfirm(){ this.confirmOpen = true; }
  closeConfirm(){ this.confirmOpen = false; }
  handleConfirmOk(){
    this.confirmOpen = false;
    showToast(this, 'Sucesso', 'Registro excluído (fake)', 'success');
  }
}
