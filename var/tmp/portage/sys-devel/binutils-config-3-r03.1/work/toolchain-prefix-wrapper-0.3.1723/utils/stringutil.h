/*
 * Copyright 2007-2012 Gentoo Foundation
 * Distributed under the terms of the GNU General Public License v2
 * Author: Michael Haubenwallner <haubi@gentoo.org>
 */

#if !defined(_STRINGUTIL_H_)
#define _STRINGUTIL_H_

#include <stdarg.h>

#if defined(__cplusplus)
extern "C" {
#endif

typedef struct _String String;

typedef struct _StringList StringList;

extern int         StringGetLength     (String const *string);
extern char const* StringGetBuffer     (String const *string);
extern String*     StringDestroy       (String *string);
extern String*     StringCreateVaConcat(char const *text
										, int length
										, va_list ap
										);
extern String*     StringCreateConcat  (char const *text
										, int length
										, ...
										);
extern String*     StringDup           (String const * origin);
extern void        StringCopy          (String* target
										, String const * source
										);
extern int         StringAppendVaConcat(String *string
										, char const *text
										, int length
										, va_list ap
										);
extern int         StringAppendConcat  (String *string
										, char const *text
										, int length
										, ...
										);
extern int         StringIsEqual       (String const *string
										, int at
										, char const *start
										, int length
										);
extern int         StringIsEqualString (String const * string
										, String const * that
										);
extern String const* GetEmptyString     (void);

extern int         StringListGetSize         (StringList const* list);
extern String const *StringListGetString     (StringList const* list, int index);
extern void        StringListClear           (StringList* list);
extern StringList* StringListDestroy         (StringList* list);
extern int         StringListAppendString    (StringList* list, String const* string);
extern int         StringListRemoveString    (StringList* list, char const* string, int length);
extern int         StringListAppendListModify(StringList* list
												, StringList const *input
												, int start
												, int count
												, char const *front
												, int frontLength
												, char const *back
												, int backLength
												);
extern int         StringListAppendList      (StringList *list
												, StringList const *input
												, int start
												, int count
												);
extern StringList* StringListCreate          (StringList const *input
												, int start
												, int count
												);
extern char **     StringListToArgv          (StringList *list);
extern int         StringListAppendVaConcat  (StringList* list
												, char const *text
												, int length
												, va_list ap
												);
extern int         StringListAppendConcat    (StringList* list
												, char const *text
												, int length
												, ...
												);
extern int         StringListAppendArgv      (StringList* list
												, int argc
												, char * const argv[]
												);
extern StringList* StringListFromArgv        (int argc, char * const argv[]);
extern int         StringListAppendSeparated (StringList* list
												, char const *text
												, int length
												, char const *sep
												, int seplength
												);
extern StringList* StringListFromSeparated   (char const *text
												, int length
												, char const *sep
												, int seplength
												);
extern int         StringListContains        (StringList const * list
												, char const *text
												, int length
												);
extern String*     StringListJoin            (StringList const * list
												, char const *start
												, int startLength
												, char const *sep
												, int sepLength
												, char const *end
												, int endLength
												);

#if defined(__cplusplus)
}
#endif

#endif /* _STRINGUTIL_H_ */
