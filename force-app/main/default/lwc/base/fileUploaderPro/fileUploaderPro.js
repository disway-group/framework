import { LightningElement, api, track } from 'lwc';
import listFiles from '@salesforce/apex/FileApi.listFiles';
import unlink from '@salesforce/apex/FileApi.unlink';
import { showToast } from 'c/toast';

export default class FileUploaderPro extends LightningElement {
  @api recordId;
  @api label='Enviar arquivos';
  @api accept='';
  @api multiple=true;
  @track files=[];

  connectedCallback(){ this.refresh(); }

  async refresh(){
    if(!this.recordId) return;
    try{
      this.files = await listFiles({ recordId:this.recordId });
    }catch(e){ /* ignore */ }
  }

  handleUploadFinished(){
    showToast(this, 'Sucesso', 'Upload concluído', 'success');
    this.refresh();
  }

  async remove(e){
    const id = e.currentTarget.dataset.id;
    try{
      await unlink({ linkId:id });
      showToast(this, 'Sucesso', 'Arquivo removido', 'success');
      this.refresh();
    }catch(ex){ showToast(this, 'Erro', 'Não foi possível remover', 'error'); }
  }
}
