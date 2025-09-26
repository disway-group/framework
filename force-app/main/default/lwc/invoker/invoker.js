// Se já existe um util que exporta showToast, importe-o.
// Ajuste o caminho conforme seu bundle (tipicamente é 'c/toast').
import { showToast } from 'c/toast';

/**
 * Invoca um método Apex com tratamento padronizado de sucesso/erro.
 *
 * @param {LightningElement} component this do componente
 * @param {Function}         apexMethod referência ao método Apex importado
 * @param {Object}           params      parâmetros do método Apex
 * @param {Object}           options
 *   - successMessage {String}
 *   - successVariant {String}    default: 'success'
 *   - successTitle   {String}    default: 'Sucesso'
 *   - voidMessage    {String}
 *   - voidVariant    {String}    default: 'info'
 *   - voidTitle      {String}    default: 'Info'
 *   - errorTitle     {String}    default: 'Erro'
 */
export async function invoke(component, apexMethod, params = {}, options = {}) {
    try {
        const result = await apexMethod(params);

        // Retorno "vazio" (void / null / undefined / string vazia)
        if (result === null || result === undefined || result === '') {
            if (options.voidMessage) {
                showToast(
                    component,
                    options.voidTitle || 'Info',
                    options.voidMessage,
                    options.voidVariant || 'info'
                );
            }
            return;
        }

        // Retorno com sucesso
        if (options.successMessage) {
            showToast(
                component,
                options.successTitle || 'Sucesso',
                options.successMessage,
                options.successVariant || 'success'
            );
        }

        return result;
    } catch (error) {
        const message =
            error?.body?.message ||
            error?.message ||
            (typeof error === 'string' ? error : JSON.stringify(error));

        showToast(component, options.errorTitle || 'Erro', message, 'error');
        throw error;
    }
}
