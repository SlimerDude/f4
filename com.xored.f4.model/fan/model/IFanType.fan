//
// Copyright (c) 2010 xored software, Inc.
// Licensed under Eclipse Public License version 1.0
//
// History:
//   Ivan Inozemtsev May 12, 2010 - Initial Contribution
//

const mixin IFanType : DltkModelElement
{
  **
  ** Parent pod which defines this type.  For parameterized types derived
  ** from List, Map, or Func, this method always returns the sys pod.
  **
  abstract Str pod()
  
  **
  ** Simple name of the type such as "Str".  For parameterized types derived
  ** from List, Map, or Func, this method always returns "List", "Map",
  ** or "Func" respectively.
  **
  abstract Str name()
  
  **
  ** Qualified name formatted as "pod::name".  For parameterized
  ** types derived from List, Map, or Func, this method always returns
  ** "sys::List", "sys::Map", or "sys::Func" respectively.  If this
  ** a nullable type, the qname does *not* include the "?".
  **
  abstract Str qname()
  
//////////////////////////////////////////////////////////////////////////
// Inheritance
//////////////////////////////////////////////////////////////////////////
  
  **
  ** List of types immediately inherited by this type as
  ** they appear in source 
  **
  abstract Str[] inheritance()
  
//////////////////////////////////////////////////////////////////////////
// Flags
//////////////////////////////////////////////////////////////////////////

  **
  ** Return if this Type is abstract and cannot be instantiated.  This
  ** method will always return true if the type is a mixin.
  **
  abstract Bool isAbstract()

  **
  ** Return if this Type is a class (as opposed to enum or mixin)
  **
  abstract Bool isClass()

  **
  ** Return if this is a const class which means instances of this
  ** class are immutable.
  **
  abstract Bool isConst()

  **
  ** Return if this Type is an Enum type.
  **
  abstract Bool isEnum()

  **
  ** Return if this Type is marked final which means it may not be subclassed.
  **
  abstract Bool isFinal()

  **
  ** Return if this Type has internal protection scope.
  **
  abstract Bool isInternal()

  **
  ** Return if this Type is a mixin type and cannot be instantiated.
  **
  abstract Bool isMixin()

  **
  ** Return if this Type has public protection scope.
  **
  abstract Bool isPublic()

  **
  ** Return if this Type was generated by the compiler.
  **
  abstract Bool isSynthetic()

 //////////////////////////////////////////////////////////////////////////
// Generics
//////////////////////////////////////////////////////////////////////////

  **
  ** Returns a list of type parameters if type is generic, empty list otherwise.
  **
  abstract Str[] params()

  **
  ** Returns new type which is copy of current type with parameters set according
  ** to 'parametrization' map.
  **
  abstract IFanType parameterize(Str:IFanType parametrization)

  **
  ** Returns a map from parameter names to types if type is parametrized, otherwise
  ** an empty map.
  **
  abstract Str:IFanType parametrization()

  **
  ** Returns a list of type parameters which are not set.
  ** 
  Str[] unsetParams() { params.exclude { parametrization[it] != null } }

  **
  ** Returns if type is has unset parameters.
  ** 
  Bool isGeneric() { !unsetParams.isEmpty }

  **
  ** Returns special names for parametrized types as 'ValueType[]' for 'List' and
  ** 'KeyType:ValueType' for 'Map'
  ** 
  abstract Str genericQname()
  
  // TODO: add equals for generics
  
//////////////////////////////////////////////////////////////////////////
// Nullability
//////////////////////////////////////////////////////////////////////////

  **
  ** Returns nullable variant of type
  ** 
  abstract IFanType toNullable()
  
  **
  ** Checks nullability
  ** 
  abstract Bool isNullable()

//////////////////////////////////////////////////////////////////////////
// Slots
//////////////////////////////////////////////////////////////////////////
  protected abstract Str:IFanSlot slotsMap()
  **
  ** List of the all defined fields (including inherited fields).
  **
  virtual IFanField[] fields() { slotsMap.vals.findAll { it is IFanField } }

  **
  ** List of the all defined methods (including inherited methods).
  **
  virtual IFanMethod[] methods() { slotsMap.vals.findAll { it is IFanMethod } }

  **
  ** List of the all defined slots, both fields and methods (including
  ** inherited slots).
  **
  virtual IFanSlot[] slots() { slotsMap.vals } 

  **
  ** Lookup a slot by name.  If the slot doesn't exist and checked
  ** is false then return null, otherwise throw UnknownSlotErr.
  **
  virtual IFanSlot? slot(Str name, Bool checked := true)
  {
    slotsMap[name] ?: (checked ? throw UnknownSlotErr() : null)
  }
  
  **
  ** Convenience for (Method)slot(name, checked)
  **
  virtual IFanMethod? method(Str name, Bool checked := true)
  {
    (slot(name, checked) as IFanMethod) ?: (checked ? throw UnknownSlotErr() : null)
  }
  
  **
  ** Convenience for (Field)slot(name, checked)
  **
  virtual IFanField? field(Str name, Bool checked := true)
  {
    (slot(name, checked) as IFanField) ?: (checked ? throw UnknownSlotErr() : null)
  }
  
  ** Find slot in this type or in super types 
  virtual IFanSlot? findSlot(Str name, IFanNamespace ns, Bool checked := true)
  {
    internalFindSlot(name,ns) ?: ( checked ? throw UnknownSlotErr() : null )
  }
  
  private IFanSlot? internalFindSlot(Str name, IFanNamespace ns, Str[] excluded := Str[,])
  {
    dirty := slot(name, false)
    if (dirty != null)
      return dirty
    excluded.add(qname)
    //deep search
    dirty = inheritance.eachWhile |base|
    {
      type := ns.findType(base)
      return type == null ? null : (excluded.contains(type.qname) ? null : type?.internalFindSlot(name,ns,excluded))
    }
    if (dirty != null || excluded.contains("sys::Obj"))
      return dirty
    return ns.findType("sys::Obj")?.internalFindSlot(name,ns,excluded)
  }
  
  virtual IFanSlot[] allSlots(IFanNamespace ns)
  {
    result := Str:IFanSlot[:]
    addSlotsTo(ns,result)
    return result.vals
  }
  
  private Void addSlotsTo(IFanNamespace ns, Str:IFanSlot map,Str[] excluded := [,])
  {
    excluded.add(qname)
    //deep search
    if (!excluded.contains("sys::Obj"))
      ns.findType("sys::Obj")?.addSlotsTo(ns,map,excluded)
    inheritance.each |t|
    {
      type := ns.findType(t)
      if(type == null) return
      if (!excluded.contains(type.qname))
        type?.addSlotsTo(ns,map,excluded)
    }
    map.setAll(slotsMap)
  }
}