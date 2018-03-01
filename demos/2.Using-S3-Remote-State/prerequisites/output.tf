##################################################################################
# OUTPUT
##################################################################################

output "sally-access-key" {
    value = "${aws_iam_access_key.sallysue.id}"
}

output "sally-secret-key" {
    value = "${aws_iam_access_key.sallysue.secret}"
}

output "mary-access-key" {
    value = "${aws_iam_access_key.marymoe.id}"
}

output "mary-secret-key" {
    value = "${aws_iam_access_key.marymoe.secret}"
}
