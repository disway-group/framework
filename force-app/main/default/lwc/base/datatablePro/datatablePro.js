import { LightningElement, api } from 'lwc';
import { i18n } from 'c/i18n';
export default class DatatablePro extends LightningElement {
  @api data=[]; @api columns=[]; @api hideCheckbox=false; @api draftValues=[]; @api emptyMessage=i18n.noRecords;
  get hasData(){ return Array.isArray(this.data) && this.data.length>0; }
  handleSave(e){ this.dispatchEvent(new CustomEvent('save', { detail: e.detail })); }
  handleRowAction(e){ this.dispatchEvent(new CustomEvent('rowaction', { detail: e.detail })); }
}
