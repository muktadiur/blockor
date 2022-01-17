.PHONY: install
install:
	@echo "Installing blockor"
	@cp -Rv ../usr /
	@cp -Rv etc /
	@cp -Rv usr /
	
.PHONY: uninstall
uninstall:
	@echo "Removing blockor"
	@rm -vf /usr/local/bin/blockor
	@rm -rvf /usr/local/libexec/blockord.sh
	@rm -rvf /usr/local/share/examples/blockor/blockor.sample.conf
	@rm -rvf /etc/rc.d/blockord
	@echo "Successfully removed blockor"
	@echo "Remove /usr/local/etc/blockor.conf if no longer needed."
