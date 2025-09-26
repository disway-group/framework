import { LightningElement, api } from 'lwc';
export default class Paginator extends LightningElement {
  @api page=1; @api total=0; @api pageSize=10;
  get totalPages(){ return Math.max(1, Math.ceil(this.total/this.pageSize)); }
  get pageSizeOptions(){ return [{label:'10', value:10},{label:'25', value:25},{label:'50', value:50},{label:'100', value:100}]; }
  prev(){ if(this.page>1){ this.page--; this.emit(); } }
  next(){ if(this.page<this.totalPages){ this.page++; this.emit(); } }
  changeSize(e){ this.pageSize=parseInt(e.detail.value,10)||10; this.page=1; this.emit(); }
  emit(){ this.dispatchEvent(new CustomEvent('change', { detail: { page:this.page, pageSize:this.pageSize } })); }
}
