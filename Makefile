.PHONY: install
install:
	@echo "Installing blockor"
	@echo
	@cp -Rv usr /
	@echo

.PHONY: uninstall
uninstall:
	@echo "Removing blockor"
	@rm -vf /usr/local/bin/blockor
	@echo
	@rm -rvf /usr/local/libexec/blockord.sh
	echo
	@rm -rvf /usr/local/share/examples/blockor/blockor.sample.conf
	@echo
	@echo "Successfully removed blockor"
	@echo
	@echo "Remove /usr/local/etc/blockor.conf if no longer needed."