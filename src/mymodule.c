#include <ucode/module.h>

/**
 * The native C function: add(a, b)
 *
 * Demonstrates basic argument retrieval, type checking, and return values.
 */
static uc_value_t *uc_native_add(uc_vm_t *vm, size_t nargs) {
  // 1. Retrieve arguments passed from .uc file
  uc_value_t *arg1 = uc_fn_arg(0);
  uc_value_t *arg2 = uc_fn_arg(1);

  // 2. Validate arguments
  if (!arg1 || ucv_type(arg1) != UC_INTEGER) {
    uc_vm_raise_exception(vm, EXCEPTION_TYPE, "First argument must be an integer");
    return NULL;
  }

  if (!arg2 || ucv_type(arg2) != UC_INTEGER) {
    uc_vm_raise_exception(vm, EXCEPTION_TYPE, "Second argument must be an integer");
    return NULL;
  }

  // 3. Extract C primitives
  int64_t val1 = ucv_int64_get(arg1);
  int64_t val2 = ucv_int64_get(arg2);

  // 4. Perform C logic
  int64_t result = val1 + val2;

  // 5. Wrap result back into a ucode object and return
  return ucv_int64_new(result);
}

/**
 * The native C function: process_object(obj)
 *
 * Demonstrates working with objects, cloning, and memory management.
 * Returns a clone of the input object with an added property "processed": true.
 */
static uc_value_t *uc_native_process_object(uc_vm_t *vm, size_t nargs) {
  uc_value_t *arg = uc_fn_arg(0);

  if (!arg || ucv_type(arg) != UC_OBJECT) {
    uc_vm_raise_exception(vm, EXCEPTION_TYPE, "Argument must be an object");
    return NULL;
  }

  // Clone the object so we don't modify the original (immutability best practice)
  // ucv_get() increments the reference count if we were keeping it, but here we want a deep copy?
  // ucode objects are reference counted. To modify "in place" but safely, usually we just set.
  // But let's creating a new object merging the old one + new field implies copy.
  // For simplicity, let's just modify the passed object if it's not readonly, or create a new one.
  
  // Let's create a NEW object and copy fields (shallow copy)
  uc_value_t *new_obj = ucv_object_new(vm);
  
  // Iterate over the input object
  ucv_object_foreach(arg, key, val) {
    // ucv_object_add takes ownership of 'val', so we must increment its refcount
    // because it's also owned by 'arg'.
    ucv_object_add(new_obj, key, ucv_get(val));
  }

  // Add our new field
  ucv_object_add(new_obj, "processed", ucv_boolean_new(true));

  return new_obj;
}

/**
 * The Function Table
 * Maps the name used in .uc files (left) to the C function pointer (right)
 */
static const uc_function_list_t mymodule_fns[] = {
    {"add", uc_native_add},
    {"process_object", uc_native_process_object}
};

void uc_module_init(uc_vm_t *vm, uc_value_t *scope) {
  uc_function_list_register(scope, mymodule_fns);
}
