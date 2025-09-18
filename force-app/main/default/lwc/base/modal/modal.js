import { LightningElement, api } from 'lwc';
export default class Modal extends LightningElement {
  @api title='Modal'; @api open=false;
  close(type='cancel'){ this.dispatchEvent(new CustomEvent(type)); }
}
