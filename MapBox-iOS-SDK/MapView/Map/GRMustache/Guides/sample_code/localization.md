[up](../../../../tree/master/Guides/sample_code), [next](../forking.md)

Localization
============

Overview
--------

Mustache and GRMustache have no built-in localization feature. It is thus a matter of injecting our own application code into the template rendering, some code that localizes its input.

[Section tag helpers](../section_tag_helpers.md) are our vector. We'll eventually render the following template:

    {{#localize}}
        Hello {{name1}}, do you know {{name2}}?
    {{/localize}}

Into the various renderings below, depending on the current locale:

    Hello Arthur, do you know Barbara?
    Bonjour Arthur, est-ce que tu connais Barbara ?
    Hola Arthur, sabes Barbara?

Yet this will be quite a smartish sample code, and it's better starting with simpler cases. We'll see how to localize:

1. a section of a template
    
        {{#localize}}Hello{{/localize}}
    
2. a value
    
        {{#localize}}{{greeting}}{{/localize}}
    
3. a portion of a template *with arguments*, as above:
    
        {{#localize}}Hello {{name1}}, do you know {{name2}}?{{/localize}}

Of course, we'll always eventually use the standard `NSLocalizedString` function.

Localizing a template section
-----------------------------

**[Download the code](../../../../tree/master/Guides/sample_code/localization)**

Let's localize the following template:

    {{#localize}}Hello{{/localize}}

And render, depending on the current locale:

    Hello
    Bonjour
    Hola

We'll execute our localizing code by attaching to the `localize` section an object that conforms to the `GRMustacheSectionTagHelper` protocol.

The shortest way to build a helper is the `[GRMustacheSectionTagHelper helperWithBlock:]` method. Its block is given a `GRMustacheSectionTagRenderingContext` object whose `innerTemplateString` property perfectly suits our needs:

```objc
id data = @{
    @"localize": [GRMustacheSectionTagHelper helperWithBlock:^(GRMustacheSectionTagRenderingContext *context) {
        return NSLocalizedString(context.innerTemplateString, nil);
    }]
};

NSString *templateString = @"{{#localize}}Hello{{/localize}}";

// Bonjour, Hola, Hello
NSString *rendering = [GRMustacheTemplate renderObject:data
                                            fromString:templateString
                                                 error:NULL];
```

`GRMustacheSectionTagHelper` and `innerTemplateString` are documented in the [section_tag_helpers.md](../section_tag_helpers.md) guide.


Localizing a value
------------------

**[Download the code](../../../../tree/master/Guides/sample_code/localization)**

Template:

    {{#localize}}{{greeting}}{{/localize}}

Data:

    { greeting: "Hello" }

Rendering:

    Hello
    Bonjour
    Hola

Again, we'll execute our localizing code by attaching to the `localize` section an object that conforms to the `GRMustacheSectionTagHelper` protocol.

However, this time, we are not localizing a raw portion of the template. Instead, we are localizing a value that comes from the rendered data.

Fortunately, `GRMustacheSectionTagRenderingContext` objects are able to provide helpers with the rendering of their inner content, `"Hello"` in our case, with their `render` method:

```objc
id data = @{
    @"greeting": @"Hello",
    @"localize": [GRMustacheSectionTagHelper helperWithBlock:^(GRMustacheSectionTagRenderingContext *context) {
        return NSLocalizedString([context render], nil);
    }]
};

NSString *templateString = @"{{#localize}}{{greeting}}{{/localize}}";

// Bonjour, Hola, Hello
NSString *rendering = [GRMustacheTemplate renderObject:data
                                            fromString:templateString
                                                 error:NULL];
```

You can see this as a "double-pass" rendering: the section is rendered once, in order to turn `{{greeting}}` into `Hello`, and the localization of this string is eventually inserted in the final rendering.

`GRMustacheSectionTagHelper` and `[GRMustacheSectionTagRenderingContext render]` are documented in the [section_tag_helpers.md](../section_tag_helpers.md) guide.


Localizing a template section with arguments
--------------------------------------------

**[Download the code](../../../../tree/master/Guides/sample_code/localization)**

Template:

    {{#localize}}
        Hello {{name1}}, do you know {{name2}}?
    {{/localize}}

Data:

    {
      name1: "Arthur",
      name2: "Barbara"
    }

Rendering:

    Hello Arthur, do you know Barbara?
    Bonjour Arthur, est-ce que tu connais Barbara ?
    Hola Arthur, sabes Barbara?

Before diving in the sample code, let's first describe out strategy:

1. We'll build the following string, the *localizable format string*:

    `Hello %@, do you know %@?`

2. We'll gather the *format arguments*:
    - `Arthur`
    - `Barbara`
    
3. We'll localize the localizable format string with `NSLocalizedString`, that will give us the *localized format string*:
    - `Hello %@, do you know %@?`
    - `Bonjour %@, est-ce que tu connais %@ ?`
    - `Hola %@, sabes %@?`

4. We'll finally use `[NSString stringWithFormat:]`, with the localized format string, and format arguments:
    - `Hello Arthur, do you know Barbara?`
    - `Bonjour Arthur, est-ce que tu connais Barbara ?`
    - `Hola Arthur, sabes Barbara?`

The tricky part is building the *localizable format string* and extracting the *format arguments*. We could most certainly "manually" parse the inner template string of the section, `Hello {{name1}}, do you know {{name2}}?`. However, we'll take a more robust and reusable path.

The [GRMustacheDelegate](../delegate.md) protocol is a nifty tool: it lets you know what GRMustache is about to render, and replace it with whatever value you want.

This looks like a nice way to build our format arguments and the localizable format string in a single strike: instead of letting GRMustache render `Arthur` and `Barbara`, we'll put those values away, and tell the library to render `%@` instead.

We'll thus now attach to the `localize` section an object that conforms to *both* the `GRMustacheSectionTagHelper` and `GRMustacheTemplateDelegate` protocols. As in the previous example, we'll perform a "double-pass" rendering: the first rendering will use the delegate side, build the localizable format string, and fill the format arguments. The second rendering will simply mix the format and the arguments.

Now the convenient `[GRMustacheSectionTagHelper helperWithBlock:]` method is not enough. Let's go for a full class:

```objc
@interface LocalizatingHelper : NSObject<GRMustacheSectionTagHelper, GRMustacheTemplateDelegate>
@property (nonatomic, strong) NSMutableArray *formatArguments;
@end

@implementation LocalizatingHelper

/**
 * GRMustacheSectionTagHelper method
 */

- (NSString *)renderForSectionTagInContext:(GRMustacheSectionTagRenderingContext *)context
{
    /**
     * Let's perform a first rendering of the section, invoking
     * [context render].
     *
     * This method returns the rendering of the section:
     * "Hello {{name1}}! Do you know {{name2}}?" in our specific example.
     *
     * Normally, it would return "Hello Arthur! Do you know Barbara?", which
     * we could not localize.
     *
     * But we are also a GRMustacheTemplateDelegate, and as such, GRMustache
     * will tell us when it is about to render a value.
     *
     * In the template:willInterpretReturnValueOfInvocation:as: delegate method,
     * we'll tell GRMustache to render "%@" instead of the actual values
     * "Arthur" and "Barbara".
     *
     * The rendering of the section will thus be "Hello %@! Do you know %@?",
     * which is a string that is suitable for localization.
     *
     * We still need the format arguments to fill the format: "Arthur", and
     * "Barbara".
     *
     * They also be gathered in the delegate method, that will fill the
     * self.formatArguments array, here initialized as an empty array.
     */

    self.formatArguments = [NSMutableArray array];
    NSString *localizableFormat = [context render]; // triggers delegate callbacks


    /**
     * Now localize the format.
     */

    NSString *localizedFormat = NSLocalizedString(localizableFormat, nil);


    /**
     * Render!
     *
     * [NSString stringWithFormat:] unfortunately does not accept an array of
     * formatArguments to fill the format. Let's support up to 3 arguments:
     */
    
    NSString *rendering = nil;
    switch (self.formatArguments.count) {
        case 0:
            rendering = localizedFormat;
            break;
        
        case 1:
            rendering = [NSString stringWithFormat:
                         localizedFormat,
                         [self.formatArguments objectAtIndex:0]];
            break;
            
        case 2:
            rendering = [NSString stringWithFormat:
                         localizedFormat,
                         [self.formatArguments objectAtIndex:0],
                         [self.formatArguments objectAtIndex:1]];
            break;
            
        case 3:
            rendering = [NSString stringWithFormat:
                         localizedFormat,
                         [self.formatArguments objectAtIndex:0],
                         [self.formatArguments objectAtIndex:1],
                         [self.formatArguments objectAtIndex:2]];
            break;
    }


    /**
     * Cleanup and return the rendering
     */

    self.formatArguments = nil;
    return rendering;
}


/**
 * GRMustacheTemplateDelegate method
 */

- (void)template:(GRMustacheTemplate *)template willInterpretReturnValueOfInvocation:(GRMustacheInvocation *)invocation as:(GRMustacheInterpretation)interpretation
{
    /**
     * invocation.returnValue is "Arthur" or "Barbara".
     *
     * Fill self.formatArguments so that we have arguments for
     * [NSString stringWithFormat:].
     */

    [self.formatArguments addObject:invocation.returnValue];


    /**
     * Render "%@" instead of the value.
     */

    invocation.returnValue = @"%@";
}

@end
```

With such a helper, the rendering is easy:

```objc
id data = @{
    @"name1": @"Arthur",
    @"name2": @"Barbara",
    @"localize": [[LocalizatingHelper alloc] init]
};

NSString *templateString = @"{{#localize}}Hello {{name1}}! Do you know {{name2}}?{{/localize}}";

// Hello Arthur, do you know Barbara?
// Bonjour Arthur, est-ce que tu connais Barbara ?
// Hola Arthur, sabes Barbara?
NSString *rendering = [GRMustacheTemplate renderObject:data
                                            fromString:templateString
                                                 error:NULL];
```

[up](../../../../tree/master/Guides/sample_code), [next](../forking.md)
