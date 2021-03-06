defmodule KV.RegistryTest do
	use ExUnit.Case, async: true

	setup context do
		{:ok, registry} = KV.Registry.start_link(context.test)
		{:ok, registry: registry}
	end

	test "spawns buckets", %{registry: registry} do
		assert KV.Registry.lookup(registry, "shopping") == :error

		KV.Registry.create(registry, "shopping")
		assert {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

		KV.Bucket.put(bucket, "milk", 1)
		assert KV.Bucket.get(bucket, "milk") == 1
	end

	test "removes buckets on exit", %{registry: registry} do
		KV.Registry.create(registry, "shopping")
		{:ok, bucket} = KV.Registry.lookup(registry, "shopping")
		Agent.stop(bucket)
		assert KV.Registry.lookup(registry, "shopping") == :error
	end

	test "removes bucket on crash", %{registry: registry} do
		KV.Registry.create(registry, "shopping2")
		{:ok, bucket} = KV.Registry.lookup(registry, "shopping2")

		# Kill the bucket and wait for the notification
		Process.exit(bucket, :shutdown)
	


		#assert_receive {:exit, "shopping2", ^bucket}

        	# I think the documentation online is misleading/wrong about this test case because
        	# according to fishcakez_ there is no way to actually sync this... but this works
        	:timer.sleep(100)


		assert KV.Registry.lookup(registry, "shopping2") == :error
	end
end
