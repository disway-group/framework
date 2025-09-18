export async function callApex(apexMethod, params = {}) {
  try {
    const result = await apexMethod(params);
    return { ok: true, data: result };
  } catch (error) {
    return { ok: false, error: parseError(error) };
  }
}
export function parseError(error) {
  return (
    error?.body?.message ||
    error?.body?.pageErrors?.[0]?.message ||
    error?.message ||
    'Unexpected error'
  );
}
