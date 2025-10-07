FROM brew.registry.redhat.io/rh-osbs/openshift-golang-builder:rhel_9_golang_1.24 AS builder

COPY . /workspace
WORKDIR /workspace/
ENV GOEXPERIMENT strictfipsruntime
RUN CGO_ENABLED=1 GOOS=linux go build -v -mod=mod -tags strictfipsruntime -o /workspace/bin/velero-plugin-for-microsoft-azure ./velero-plugin-for-microsoft-azure

FROM registry.redhat.io/ubi9/ubi:latest
RUN dnf -y install openssl && dnf -y reinstall tzdata && dnf clean all
RUN mkdir /plugins
COPY --from=builder /workspace/bin/velero-plugin-for-microsoft-azure /plugins/
COPY LICENSE /licenses/
USER 65534:65534
ENTRYPOINT ["/bin/bash", "-c", "cp /plugins/* /target/."]

LABEL description="OpenShift API for Data Protection - Velero Plugin for MICROSOFT-AZURE"
LABEL io.k8s.description="OpenShift API for Data Protection - Velero Plugin for MICROSOFT-AZURE"
LABEL io.k8s.display-name="OADP Velero Plugin for MICROSOFT-AZURE"
LABEL io.openshift.tags="migration"
LABEL summary="OpenShift API for Data Protection - Velero Plugin for MICROSOFT-AZURE"
