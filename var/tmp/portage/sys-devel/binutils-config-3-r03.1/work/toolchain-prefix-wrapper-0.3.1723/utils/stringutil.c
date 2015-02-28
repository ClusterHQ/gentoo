/*
 * Copyright 2007-2012 Gentoo Foundation
 * Distributed under the terms of the GNU General Public License v2
 * Author: Michael Haubenwallner <haubi@gentoo.org>
 */

#include "stringutil.h"

#include <string.h>
#include <stdlib.h>

typedef struct _Content {
	int referenceCount;
	int length;
	int reserved;
	char *buffer;
} Content;

static inline Content* ContentDestroy(Content* content)
{
	if (content == NULL) {
		return NULL;
	}
	if (content->buffer) {
		free((void*)content->buffer);
	}
	content->buffer = NULL;
	content->length = 0;
	content->reserved = 0;
	free(content);
	return NULL;
}

static inline Content* ContentUnref(Content* content)
{
	if (content == NULL) {
		return NULL;
	}
	-- content->referenceCount;
	if (content->referenceCount > 0) {
		return NULL;
	}
	return ContentDestroy(content);
}

static inline Content* ContentRef(Content* content)
{
	if (content != NULL) {
		++ content->referenceCount;
	}
	return content;
}

static inline Content* ContentCreate(int reserve)
{
	Content* content = (Content*)malloc(sizeof(Content));
	if (content == NULL) {
		return NULL;
	}
	content->referenceCount = 0;
	content->length = 0;
	content->reserved = 0;
	content->buffer = NULL;

	content->reserved = reserve + 1;
	content->buffer = (char*)malloc(content->reserved * sizeof(char));

	if (content->buffer == NULL) {
		content = ContentDestroy(content);
	}

	return content;
}

static inline int ContentAppend(Content* content, char const *text, int length)
{
	if (content == NULL) return -1;
	if (text == NULL) return 0;
	if (length < 0) length = strlen(text);
	if (length == 0) return 0;
	if (content->length + length >= content->reserved) return -1;
	memmove(content->buffer + content->length, text, length * sizeof(char));
	content->length += length;
	content->buffer[content->length] = '\0';
	return 0;
}

static inline Content* ContentCreateVaConcat(Content *orig, char const *text, int length, va_list ap)
{
	Content* content = NULL;
	int concatLength;
	char const * arg;
	int argLength;
	int err;
	va_list aptmp;

	do {
		err = 1;

		concatLength = 0;

		if (orig && orig->buffer) {
			concatLength += orig->length;
		}

		if (text) {
			if (length < 0) {
				length = strlen(text);
			}
			concatLength += length;
		}

		va_copy(aptmp, ap);
		do {
			arg = va_arg(aptmp, char*);
			if (arg == NULL) {
				break;
			}
			argLength = va_arg(aptmp, int);
			if (argLength < 0) {
				argLength = strlen(arg);
			}
			concatLength += argLength;
		} while(1);

		content = ContentCreate(concatLength);
		if (content == NULL) break;

		if (orig && orig->buffer) {
			if (ContentAppend(content, orig->buffer, orig->length) < 0) break;
		}

		/* length checked above already */
		if (text) {
			if (ContentAppend(content, text, length) < 0) break;
		}

		va_copy(aptmp, ap);
		do {
			arg = va_arg(aptmp, char*);
			if (arg == NULL) {
				break;
			}
			argLength = va_arg(aptmp, int);
			if (argLength < 0) {
				argLength = strlen(arg);
			}

			if (ContentAppend(content, arg, argLength) < 0) break;
		} while(1);

		err = 0;
	} while(0);

	if (err && content) content = ContentDestroy(content);

	return content;
}

static inline char * ContentExtractBuffer(Content* content)
{
	char *ret = NULL;
	if (content == NULL) {
		return NULL;
	}
	ret = content->buffer;
	content->buffer = NULL;
	content->length = 0;
	return ret;
}

static inline int ContentGetLength(Content const * content)
{
	if (content == NULL) {
		return -1;
	}
	return content->length;
}

static inline char const* ContentGetBuffer(Content const * content)
{
	if (content == NULL) {
		return NULL;
	}
	return content->buffer;
}

/*
 * String with CopyOnWrite semantics
 */

struct _String {
	Content* content;
};

int StringGetLength(String const *string)
{
	if (string == NULL) {
		return -1;
	}
	return ContentGetLength(string->content);
}

char const* StringGetBuffer(String const *string)
{
	if (string == NULL) {
		return NULL;
	}
	return ContentGetBuffer(string->content);
}

String* StringDestroy(String *string)
{
	if (string == NULL) {
		return NULL;
	}

	string->content = ContentUnref(string->content);
	free(string);
	return NULL;
}

static String* StringCreate(Content* content)
{
	String *string = (String*)malloc(sizeof(String));
	if (string == NULL) return NULL;
	if (content) string->content = ContentRef(content);
	return string;
}

String* StringCreateVaConcat(char const *text, int length, va_list ap)
{
	Content *content = NULL;
	String *string = NULL;
	int err;

	do {
		err = 1;

		Content *content = ContentCreateVaConcat(NULL, text, length, ap);
		if (content == NULL) break;

		string = StringCreate(content);
		if (string == NULL) break;

		/* do not destroy content, is stored in string */
		content = NULL;

		err = 0;
	} while(0);

	if (err && string) string = StringDestroy(string);
	if (content) content = ContentDestroy(content);

	return string;
}

String* StringCreateConcat(char const *text, int length, ...)
{
	String* string;

	va_list ap;
	va_start(ap, length);
	string = StringCreateVaConcat(text, length, ap);
	va_end(ap);

	return string;
}

String* StringDup(String const * origin)
{
	if (origin == NULL) {
		return StringCreateConcat(NULL, 0, NULL);
	}

	return StringCreate(origin->content);
}

void StringCopy(String* target, String const * source)
{
	ContentUnref(target->content);
	target->content = ContentRef(source->content);
	return;
}

int StringAppendVaConcat(String *string, char const *text, int length, va_list ap)
{
	Content *newContent;
	if (string == NULL) {
		return 0;
	}
	newContent = ContentCreateVaConcat(string->content, text, length, ap);
	if (newContent == NULL) {
		return -1;
	}

	ContentUnref(string->content);
	string->content = ContentRef(newContent);

	return 0;
}

int StringAppendConcat(String *string, char const *text, int length, ...)
{
	int ret;
	va_list ap;

	va_start(ap, length);
	ret = StringAppendVaConcat(string, text, length, ap);
	va_end(ap);

	return 0;
}

int StringIsEqual(String const *string, int at, char const *start, int length)
{
	int rv = 0;
	char const *buffer = NULL;
	int buflen = 0;
	if (string == NULL) {
		if (start == NULL) {
			return 1;
		}
		return 0;
	}
	buffer = ContentGetBuffer(string->content);
	buflen = ContentGetLength(string->content);
	if (buffer == NULL || at > buflen) {
		buflen = 0;
		buffer = "";
	}
	if (at <= buflen) {
		buffer += at;
	}
	if (start == NULL) {
		start = "";
		length = 0;
	}
	if (length < 0) {
		return strcmp(buffer, start) ? 0 : 1;
	}

	if (rv == 0) rv = length - buflen;
	if (rv == 0) rv = strncmp(buffer, start, length);
	return rv ? 0 : 1;
}

int StringIsEqualString(String const * string, String const * that)
{
	if (string == NULL || that == NULL) {
		return 0;
	}
	if (string->content == that->content) {
		return 1;
	}
	return 0 == strcmp(ContentGetBuffer(string->content), ContentGetBuffer(that->content));
}

static char* StringExtractBuffer(String *string)
{
	if (string == NULL) {
		return NULL;
	}
	return ContentExtractBuffer(string->content);
}

String const* GetEmptyString(void)
{
	static String* emptyString = NULL;
	if (emptyString == NULL) {
		emptyString = StringCreateConcat("", 0, NULL);
	}
	return emptyString;
}

/*
 * StringList
 */

struct _StringList {
	int size;
	int alloced;
	String **list;
};

int StringListGetSize(StringList const *list)
{
	if (list == NULL) {
		return -1;
	}
	return list->size;
}

String const *StringListGetString(StringList const *list, int index)
{
	if (list == NULL || list->size <= index || index < 0) {
		return NULL;
	}
	return list->list[index];
}

void StringListClear(StringList* list)
{
	if (list == NULL) {
		return;
	}

	while(list->size > 0) {
		list->size --;
		list->list[list->size] = StringDestroy(list->list[list->size]);
	}
	if (list->list != NULL) {
		free(list->list);
		list->list = NULL;
	}
	list->alloced = 0;

	return;
}

StringList *StringListDestroy(StringList *list)
{
	if (list == NULL) {
		return NULL;
	}

	StringListClear(list);

	free(list);
	return NULL;
}

int StringListAppendString(StringList *list, String const *string)
{
	if (string == NULL) {
		return 0;
	}
	if (list->size == list->alloced) {
		/* always have trailing NULL string in list */
		String **tmp = (String**)realloc(list->list, (list->alloced + 5) * sizeof(char*));
		if (tmp == NULL) {
			return -1;
		}
		list->list = tmp;
		list->alloced += 5;
	}
	list->list[list->size] = StringDup(string);
	if (list->list[list->size] == NULL) {
		return -1;
	}
	++ list->size;
	return 0;
}

/* Removes all occurrences of string from list */
int StringListRemoveString(StringList *list, char const *string, int length)
{
	int i;
	int ret = 0;
	if (string == NULL) {
		return 0;
	}

	for (i = 0; i < list->size; i++) {
		if (StringIsEqual(list->list[i], 0, string, length)) {
			int j;
			list->list[i] = StringDestroy(list->list[i]);
			/* better remain order preserving here, expensive as it is */
			for (j = i + 1; j < list->size; j++)
				list->list[j - 1] = list->list[j];
			list->list[j - 1] = NULL;
			ret = 1;
			list->size--;
		}
	}
	return ret;
}

int StringListAppendListModify(StringList *list, StringList const *input, int start, int count
		, char const *front, int frontLength
		, char const *back, int backLength
		)
{
	if (list == NULL || input == NULL || start >= StringListGetSize(input)) {
		return 0;
	}

	if (front && frontLength < 0) frontLength = strlen(front);
	if (back && backLength < 0) backLength = strlen(back);

	if (count > 0 && start + count > StringListGetSize(input)) {
		count = StringListGetSize(input) - start;
	}

	if (count < 0) {
		count = StringListGetSize(input) - start;
	}

	while(--count >= 0) {
		if (front || back) {
			if (StringListAppendConcat(list
					, front ? front : "", front ? frontLength : 0
					, StringGetBuffer(input->list[start]), StringGetLength(input->list[start])
					, back ? back : "", back ? backLength : 0
			, NULL) < 0) break;
			start++;
		} else {
			if (StringListAppendString(list, input->list[start++]) < 0) break;
		}
	}
	if (count >= 0) {
		return -1;
	}
	return 0;
}

int StringListAppendList(StringList *list, StringList const *input, int start, int count)
{
	return StringListAppendListModify(list, input, start, count, NULL, 0, NULL, 0);
}

StringList *StringListCreate(StringList const *input, int start, int count)
{
	StringList *list = (StringList*)malloc(sizeof(StringList));
	if (list == NULL) {
		return NULL;
	}
	list->size = 0;
	list->alloced = 0;
	list->list = NULL;

	if (StringListAppendList(list, input, start, count) < 0) {
		list = StringListDestroy(list);
	}
	return list;
}

char **StringListToArgv(StringList *list)
{
	char **argv;
	if (list == NULL) {
		return NULL;
	}
	argv = (char**)malloc((list->size + 1) * sizeof(char*));
	if (argv == NULL) {
		return NULL;
	}

	argv[list->size] = NULL;
	while(list->size > 0) {
		list->size --;
		argv[list->size] = StringExtractBuffer(list->list[list->size]);
		list->list[list->size] = StringDestroy(list->list[list->size]);
	}

	return argv;
}

int StringListAppendVaConcat(StringList* list, char const *text, int length, va_list ap)
{
	int rv;
	String *tmp = StringCreateVaConcat(text, length, ap);
	if (tmp == NULL) {
		return -1;
	}

	rv = StringListAppendString(list, tmp);

	tmp = StringDestroy(tmp);

	return rv;
}

int StringListAppendConcat(StringList* list, char const *text, int length, ...)
{
	int ret;
	va_list ap;
	va_start(ap, length);
	ret = StringListAppendVaConcat(list, text, length, ap);
	va_end(ap);
	return ret;
}

int StringListAppendArgv(StringList* list, int argc, char * const argv[])
{
	if (argc < 0) {
		argc = 0;
		while(*argv != NULL) ++argc;
	}
	while (--argc >= 0) {
		if (StringListAppendConcat(list, *(argv++), -1, NULL) < 0) break;
	}
	if (argc >= 0) {
		return -1;
	}
	return 0;
}

StringList* StringListFromArgv(int argc, char * const argv[])
{
	StringList *list = NULL;
	list = StringListCreate(NULL, 0, 0);
	if (list == NULL) {
		return NULL;
	}
	if (StringListAppendArgv(list, argc, argv) < 0) {
		list = StringListDestroy(list);
	}

	return list;
}

int StringListAppendSeparated(StringList* list, char const *text, int length, char const *sep, int seplength)
{
	char const *next;
	int addlength;

	if (sep == NULL) {
		sep = " ";
		seplength = 1;
	} else if (seplength < 0) {
		seplength = strlen(sep);
	}

	while(text != NULL && length != 0) {
		/* note: length can be -1 */
		addlength = length;
		next = strstr(text, sep);
		if (next != NULL) {
			addlength = next - text;
			next += seplength;
		}
		if (length >= 0) {
			if (addlength > length) {
				addlength = length;
				next = NULL;
			}
			length -= addlength;
		}
		if (StringListAppendConcat(list, text, addlength, NULL) < 0) break;
		text = next;
	}

	if (text != NULL && length != 0) {
		return -1;
	}

	return 0;
}

StringList* StringListFromSeparated(char const *text, int length, char const *sep, int seplength)
{
	StringList *list = NULL;
	list = StringListCreate(NULL, 0, 0);
	if (list == NULL) {
		return NULL;
	}
	if (StringListAppendSeparated(list, text, length, sep, seplength) < 0) {
		list = StringListDestroy(list);
	}

	return list;
}

int StringListContains(StringList const * list, char const *text, int length)
{
	int i;
	for(i = 0; i < list->size; i++) {
		if (StringIsEqual(list->list[i], 0, text, length)) {
			return 1;
		}
	}
	return 0;
}

String* StringListJoin(StringList const * list
		, char const *start, int startLength
		, char const *sep, int sepLength
		, char const *end, int endLength)
{
	Content *content = NULL;
	String *result = NULL;
	int i, err;
	int length = 0;

	if (start && startLength < 0) startLength += strlen(start);
	if (sep && sepLength < 0) sepLength += strlen(sep);
	if (end && endLength < 0) endLength += strlen(end);

	if (start) length += startLength;

	for(i = 0; i < list->size; i++) {
		if (i > 0 && sep) length += sepLength;
		length += StringGetLength(list->list[i]);
	}

	if (end) length += endLength;

	do {
		err = 1;

		content = ContentCreate(length);
		if (content == NULL) break;

		if (start) if (ContentAppend(content, start, startLength) < 0) break;

		for(i = 0; i < list->size; i++) {
			if (i > 0 && sep) ContentAppend(content, sep, sepLength);
			if (ContentAppend(content,
					StringGetBuffer(list->list[i]), StringGetLength(list->list[i])
			)) break;
		}
		if (i < list->size) break;

		if (end) if (ContentAppend(content, end, endLength) < 0) break;

		result = StringCreate(content);
		if (result == NULL) break;

		/* do not destroy content, is stored in string */
		content = NULL;

		err = 0;
	} while(0);

	if (err && result) result = StringDestroy(result);

	if (content) content = ContentUnref(content);

	return result;
}

