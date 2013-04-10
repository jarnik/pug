package pug.model.utils;

class XmlFormatter {
	public static function stringify(xml: Xml, buf: StringBuf, indent: String) {
		buf.add(indent);
		buf.add("<");
		buf.add(xml.nodeName);
		
		// writing attributes
		for (att in xml.attributes()) {
			buf.add(" ");
			buf.add(att);
			buf.add("=\"");
			buf.add(xml.get(att));
			buf.add("\"");
		}
		// now subnodes or cdata
		if (xml.iterator().hasNext()) { 
			buf.add(">");
			// if we have subnodes
			if (xml.elements().hasNext()) {
				buf.add("\n");
				for (el in xml.elements()) {
					stringify(el, buf, indent + "  ");
				}
				buf.add(indent);
			} else {
				// and this is for cdata - only one is processed
				var cdata = xml.iterator().next();
				buf.add("<![CDATA[");
				buf.add(cdata.nodeValue);
				buf.add("]]>");
			}
			buf.add("</");
			buf.add(xml.nodeName);
			buf.add(">");
		} else {
			buf.add("/>");
		}
		buf.add("\n");
	}
}
