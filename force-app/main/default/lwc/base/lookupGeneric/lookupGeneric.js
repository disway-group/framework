import { LightningElement, api, track } from 'lwc';
import searchRecords from '@salesforce/apex/LookupApi.searchRecords';
const DEBOUNCE = 280;

export default class LookupGeneric extends LightningElement {
  @api label='Lookup';
  @api placeholder='Pesquisar...';
  @api objectApiName;
  @api fields='Name';
  @api subtitleFields='';
  @api whereClause='';
  @api recordTypeDeveloperName;
  @api disabled=false; @api required=false; @api minChars=2; @api helpText;
  @api multi=false; @api maxSelections=5;

  @track options=[]; @track selections=[];
  open=false; query='';

  get hasOptions(){ return (this.options||[]).length>0; }
  get hasSelection(){ return this.multi ? this.selections.length>0 : !!this.singleSelection; }
  get singleSelection(){ return this.selections[0]; }

  _timer;
  handleChange(e){
    this.query = e.target.value;
    if((this.query||'').length < this.minChars){ this.options=[]; return; }
    clearTimeout(this._timer);
    this._timer = setTimeout(()=> this.fetch(), DEBOUNCE);
  }
  openMenu(){ this.open=true; }
  handleBlur(){ setTimeout(()=> this.open=false, 150); }

  async fetch(){
    const params = { objectApiName:this.objectApiName, term:this.query, fields:this.fields, subtitleFields:this.subtitleFields,
      whereClause:this.whereClause, recordTypeDeveloperName:this.recordTypeDeveloperName, limitSize:20 };
    try {
      const rows = await searchRecords(params);
      this.options = (rows||[]).map(r => ({ id:r.id, title:r.title, subtitle:r.subtitle }));
      this.open = true;
    } catch(e){ this.options=[]; this.open=true; }
  }

  select(e){
    const id = e.currentTarget.dataset.id;
    const label = e.currentTarget.dataset.label;
    const pill = { id, label };
    if(this.multi){
      if(this.selections.find(p=>p.id===id)) return;
      if(this.selections.length >= this.maxSelections) return;
      this.selections = [...this.selections, pill];
      this.emit();
    } else {
      this.selections = [pill];
      this.emit();
    }
  }

  removePill(e){
    const id = e.target.name;
    this.selections = this.selections.filter(p=>p.id!==id);
    this.emit();
  }

  clear(){
    this.selections = [];
    this.emit();
  }

  emit(){
    const detail = this.multi ? { ids:this.selections.map(p=>p.id), labels:this.selections.map(p=>p.label) }
                              : (this.singleSelection ? { id:this.singleSelection.id, label:this.singleSelection.label } : { id:null });
    this.dispatchEvent(new CustomEvent('select', { detail }));
  }

  @api get value(){ return this.multi ? this.selections.map(p=>p.id) : (this.singleSelection && this.singleSelection.id); }
}
