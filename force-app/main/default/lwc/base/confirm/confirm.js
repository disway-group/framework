import { LightningElement, api } from 'lwc';
import { i18n } from 'c/i18n';
export default class Confirm extends LightningElement {
  @api open=false; @api title=i18n.confirm; @api message='Tem certeza?';
  @api cancelLabel=i18n.cancel; @api okLabel=i18n.ok;
  handleCancel(){ this.dispatchEvent(new CustomEvent('cancel')); }
  handleOk(){ this.dispatchEvent(new CustomEvent('ok')); }
}
