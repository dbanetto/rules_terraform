load("@rules_terraform//internal:download.bzl", "terraform_provider_download", "terraform_download")

def _tf_deps(ctx):
    version_defined = None

    for mod in ctx.modules:
        for version in mod.tags.version:
            if version_defined != None:
                fail("terraform versions are defined twice, {} and {}".format(version_defined.version, version.version))
            terraform_download(
                name = "terraform",
                sha256 = version.sha256,
                version = version.version,
            )
            version_defined = version

        for provider in mod.tags.provider:
            terraform_provider_download(
                name = "tf_provider_{}".format(provider.name),
                provider_name = provider.name,
                sha256 = provider.sha256,
                version = provider.version,
                source = provider.source,
                download_base_url = provider.download_base_url,
            )

    if version_defined == None:
        fail("terraform versions is defined")


_provider = tag_class(
    attrs = {
       "name" : attr.string(), 
       "sha256" : attr.string(), 
       "version" : attr.string(), 
       "source" : attr.string(), 
       "download_base_url" : attr.string(
           default = "https://releases.hashicorp.com/terraform-provider-{name}/{version}",
       ), 
    }
)

_version = tag_class(
    attrs = {
       "version": attr.string(), 
       "sha256": attr.string(), 
    }
)

tf_deps = module_extension(
    implementation = _tf_deps,
    tag_classes = {
        "provider": _provider,
        "version": _version
    },
)
