# parse-skaffold-render
Parses skaffold render file and separates all k8s objects into files and directories analogue to the source they've been created from.

Can be invoked by passing the render file as a parameter, or using pipes as in `cat render-file.yaml | parse-skaffold.sh`

