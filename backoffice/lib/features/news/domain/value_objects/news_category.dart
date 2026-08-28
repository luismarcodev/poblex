final RegExp _categorySlugPattern = RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$');

bool isValidNewsCategory(String value) =>
    _categorySlugPattern.hasMatch(value.trim());
