"""Core XML support for Python.

This package contains four sub-packages:

dom -- The W3C Document Object Model.  This supports DOM Level 1 +
       Namespaces.

parsers -- Python wrappers for XML parsers (currently only supports Expat).

sax -- The Simple API for XML, developed by XML-Dev, led by David
       Megginson and ported to Python by Lars Marius Garshol.  This
       supports the SAX 2 API.

etree -- The ElementTree XML library.  This is a subset of the full
       ElementTree XML release.

"""


__all__ = ["dom", "parsers", "sax", "etree"]

_MINIMUM_XMLPLUS_VERSION = (0, 8, 4)


def use_pyxml():
    import _xmlplus
    v = _xmlplus.version_info
    if v >= _MINIMUM_XMLPLUS_VERSION:
        import sys
        _xmlplus.__path__.extend(__path__)
        sys.modules[__name__] = _xmlplus
        cleared_modules = []
        redefined_modules = []
        for module in sys.modules:
            if module.startswith("xml.") and not module.startswith(("xml.marshal", "xml.schema", "xml.utils", "xml.xpath", "xml.xslt")):
                cleared_modules.append(module)
            if module.startswith(("xml.__init__", "xml.dom", "xml.parsers", "xml.sax")) and sys.modules[module] is not None:
                redefined_modules.append(module)
        for module in cleared_modules:
            del sys.modules[module]
        for module in sorted(redefined_modules):
            __import__(module)
    else:
        raise ImportError("PyXML too old: %s" % ".".join(str(x) for x in v))
